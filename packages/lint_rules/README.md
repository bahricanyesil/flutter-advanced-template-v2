# lint_rules

A custom set of linting rules and guidelines for maintaining code quality and consistency across projects.

## Overview

The `lint_rules` package provides a centralized configuration for linting in your Flutter and Dart projects. This package enforces best practices, ensuring that your codebase remains clean, consistent, and easy to maintain.

## Features

- Predefined lint rules tailored for your project.
- Enforces code formatting, naming conventions, and common best practices.
- Helps identify potential issues early in the development process.

## Usage

1. Add the `lint_rules` package to your project's `pubspec.yaml`:

  ```yaml
  dev_dependencies:
  lint_rules:
    git:
      url: https://github.com/bahricanyesil/flutter-advanced-template-v2.git
      path: packages/lint_rules
  ```

  or as a path dependency

  ```yaml
  dev_dependencies:
    lint_rules:
      path: ../path_to_lint_rules
  ```
