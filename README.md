# AudiobookRenamePS

Powershell scripts for audiobook collection renaming
Please backup your files before using this 
## How to Use

### Precheck

First, run `precheck.ps1`. This will check if the audiobook has any issues like duplicated names, missing `metadata.json`, and so on:

`precheck.ps1 -path $targetPath`

If there are no errors listed, the script will output an "Audiobook Precheck Passed" message. Otherwise, it will list all audiobook folders with problems and an "Audiobook Precheck Failed" message.

### Update Audiobook

After resolving all precheck problems, run `updateAudiobookNaming.ps1` to update the audiobook folder and file names:

`updateAudiobookNaming.ps1 -path $targetPath`

### Notes

- Currently, renaming will only use the `%author% - %album%/%album%` format.
- `updateAudiobookNaming.ps1` will exclude the translator, editor, illustrator, and so on. This is configurable by using the `-AuthorExcludePattern` parameter.
- `updateAudiobookNaming.ps1` by default will limit the author to 3. This is configurable by using the `-AuthorLimit` parameter.
- Could use `-dryrun` for an `updateAudiobookNaming.ps1` test run.
