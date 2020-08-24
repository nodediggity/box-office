//
//  LoadMovieFromRemoteUseCaseTests.swift
//  BoxOfficeMovieDetailsTests
//
//  Created by Gordon Smith on 24/08/2020.
//  Copyright © 2020 Gordon Smith. All rights reserved.
//

import XCTest
import BoxOfficeNetworking
import BoxOfficeMovieDetails

class RemoteMovieLoader {

  typealias Result = Swift.Result<Movie, Error>

  enum Error: Swift.Error {
    case connectivity
    case invalidResponse
  }

  private let baseURL: URL
  private let client: HTTPClient

  init(baseURL: URL, client: HTTPClient) {
    self.baseURL = baseURL
    self.client = client
  }

  func load(id: Int, completion: @escaping (Result) -> Void) {
    client.dispatch(URLRequest(url: enrich(baseURL, with: id)), completion: { [weak self] result in
      guard self != nil else { return }
      switch result {
        case let .success((data, response)): completion(RemoteMovieLoader.map(data, from: response))
        case .failure: completion(.failure(Error.connectivity))
      }
    })
  }
}

private extension RemoteMovieLoader {
  func enrich(_ url: URL, with movieID: Int) -> URL {
    return url
      .appendingPathComponent("3")
      .appendingPathComponent("movie")
      .appendingPathComponent("\(movieID)")
  }

  static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    do {
      let value = try MovieMapper.map(data, from: response)
      return .success(value.asMovie)
    } catch {
      return .failure(.invalidResponse)
    }
  }
}

struct RemoteMovie: Decodable {

  struct RemoteMovieGenre: Decodable {
    let name: String
  }

  let id: Int
  let original_title: String
  let vote_average: CGFloat
  let runtime: CGFloat
  let genres: [RemoteMovieGenre]
  let overview: String
  let backdrop_path: String
}

final class MovieMapper {

  private static var OK_200: Int { return 200 }

  static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteMovie {
    guard response.statusCode == OK_200, let page = try? JSONDecoder().decode(RemoteMovie.self, from: data) else {
      throw RemoteMovieLoader.Error.invalidResponse
    }

    return page
  }
}

private extension RemoteMovie {
  var asMovie: Movie {
    return Movie(id: id, title: original_title, rating: vote_average, length: runtime, genres: genres.map { $0.name }, overview: overview, backdropImagePath: backdrop_path)
  }
}


class LoadMovieFromRemoteUseCaseTests: XCTestCase {

  func test_on_init_does_not_request_data_from_remote() {
    let (_, client) = makeSUT()
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_load_requests_data_from_remote() {
    let movieID = 1
    let expectedURL = makeURL("https://some-remote-svc.com/3/movie/\(movieID)")
    let baseURL = makeURL("https://some-remote-svc.com")
    let (sut, client) = makeSUT(baseURL: baseURL)

    sut.load(id: movieID, completion: { _ in })

    XCTAssertEqual(client.requestedURLs, [expectedURL])
  }

  func test_load_requests_data_from_remote_on_each_call() {
    let movieID = 1
    let expectedURL = makeURL("https://some-remote-svc.com/3/movie/\(movieID)")
    let baseURL = makeURL("https://some-remote-svc.com")
    let (sut, client) = makeSUT(baseURL: baseURL)

    sut.load(id: movieID, completion: { _ in })
    sut.load(id: movieID, completion: { _ in })

    XCTAssertEqual(client.requestedURLs, [expectedURL, expectedURL])
  }

  func test_load_delivers_error_on_client_error() {
    let (sut, client) = makeSUT()
    let error = makeError()
    expect(sut, toCompleteWith: failure(.connectivity), when: {
      client.completes(with: error)
    })
  }

  func test_load_delivers_error_on_non_success_response() {
    let (sut, client) = makeSUT()
    let samples = [299, 300, 399, 400, 418, 499, 500]
    let data = makeData()
    samples.indices.forEach { index in
      expect(sut, toCompleteWith: failure(.invalidResponse), when: {
        client.completes(withStatusCode: samples[index], data: data, at: index)
      })
    }
  }

  func test_load_delivers_error_on_success_response_with_invalid_json() {
    let (sut, client) = makeSUT()
    let invalidJSONData = Data("invalid json".utf8)
    expect(sut, toCompleteWith: failure(.invalidResponse), when: {
      client.completes(withStatusCode: 200, data: invalidJSONData)
    })
  }

  func test_load_delivers_movie_on_success_response_with_valid_json() {
    let (sut, client) = makeSUT()
    let movie = makeMovie()
    let movieData = makeMovieJSONData(for: movie.json)
    expect(sut, toCompleteWith: .success(movie.model), when: {
      client.completes(withStatusCode: 200, data: movieData)
    })
  }

  func test_does_not_invoke_completion_once_instance_has_been_deallocated() {
    let client = HTTPClientSpy()
    var sut: RemoteMovieLoader? = RemoteMovieLoader(baseURL: makeURL(), client: client)

    var output: Any? = nil
    sut?.load(id: 1, completion: { output = $0 })
    sut = nil

    client.completes(withStatusCode: 200, data: makeData())
    XCTAssertNil(output)
  }
}

private extension LoadMovieFromRemoteUseCaseTests {
  func makeSUT(baseURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> (RemoteMovieLoader, HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteMovieLoader(baseURL: baseURL ?? makeURL(), client: client)

    checkForMemoryLeaks(client, file: file, line: line)
    checkForMemoryLeaks(sut, file: file, line: line)

    return (sut, client)
  }

  func expect(_ sut: RemoteMovieLoader, toCompleteWith expectedResult: RemoteMovieLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    sut.load(id: 0, completion: { receivedResult in
      switch (receivedResult, expectedResult) {
        case let (.success(receivedMovie), .success(expectedMovie)):
          XCTAssertEqual(receivedMovie, expectedMovie, file: file, line: line)
        case let (.failure(receivedError as NSError?), .failure(expectedError as NSError?)):
          XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
          XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    })
    action()
    wait(for: [exp], timeout: 1.0)
  }

  func failure(_ error: RemoteMovieLoader.Error) -> RemoteMovieLoader.Result {
    return .failure(error)
  }

  func makeMovieJSONData(for items: [String: Any]) -> Data {
    let data = try! JSONSerialization.data(withJSONObject: items)
    return data
  }

  func makeMovie() -> (model: Movie, json: [String: Any]) {

    let model = Movie(
      id: 1,
      title: "thrilling action movie",
      rating: 8,
      length: 139,
      genres: ["action", "thriller"],
      overview: "a thrilling movie with lots of action",
      backdropImagePath: "some-cool-image.png"
    )

    let json = [
      "id": model.id,
      "original_title": model.title,
      "vote_average": model.rating,
      "runtime": model.length,
      "genres": model.genres.map { ["name": $0] },
      "overview": model.overview,
      "backdrop_path": model.backdropImagePath
    ] as [String: Any]

    return (model, json)
  }
}
