# box-office
> Box Office is a concept app intended to show best practice when working with paged API responses

## Getting started
You'll need to obtain a free secret key from [here](https://developers.themoviedb.org/3/getting-started/authentication)

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>secret</key>
	<string>_YOUR SECRET KEY_</string>
</dict>
</plist>
```

## Commit messages

Commit message should adhere to the [`Conventional Commits`](https://www.conventionalcommits.org/en/v1.0.0/) style and be structured as follows:

Format: `<type>(<scope>): <subject>`

`<scope>` is optional

### Example

```
feat: add something new
^--^  ^---------------^
|     |
|     +-> Summary in present tense.
|
+-------> Type: chore, docs, feat, fix, refactor, style, or test.
```

More Examples:

- `feat`: (new feature for the user, not a new feature for build script)
- `fix`: (bug fix for the user, not a fix to a build script)
- `docs`: (changes to the documentation)
- `style`: (formatting, missing semi colons, etc; no production code change)
- `refactor`: (refactoring production code, eg. renaming a variable)
- `test`: (adding missing tests, refactoring tests; no production code change)
- `chore`: (updating grunt tasks etc; no production code change)