# Repolinter Auditor

## Introduction
This is designed to be used in GitHub Actions.  This looks at the output of Repolinter and makes the data accessible to a GitHub Actions workflow, so decisions can be made within the pipelie.

## Inputs
| Input | Type | Description |
|-------|------|-------------|
| `json_results_filelicenses_file` | string | The file output from Repolinter.  Defaults to `repolinter_results.json`. |

## Outputs
| Output | Type | Description |
|-------|------|-------------|
| `passed` | bool | Whether or not it passed. |
| `errored` | bool | Whether or not it errored. |
| `readme_file_found` | bool | Whether or not a README file was found. |
| `readme_file_details` | string | 'The details of the README file check' |
| `license_file_found` | bool | Whether or not a LICENSE file was found. |
| `license_file_details` | string | The details of the LICENSE file check. |
| `blacklisted_words_found` | bool | Whether or not blacklisted words were found. |
| `blacklisted_words_details` | string | The details of the blacklisted words check. |
| `copyright_found` | bool | Whether or not copyright notices were found. |
| `copyright_details` | string | The details of the copyright check. |

## Usage
Coming soon!

## Copyright Notice
Copyright (c) 2021 Oracle and/or its affiliates.