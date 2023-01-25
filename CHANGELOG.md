## [Unreleased]

## [1.2.0] - 2023-01-25

### Breaking changes

- Inline view syntax has been changed from `view :[view_type] { '[content]' }` to `view '[content]', type: :[view_type]`

- Overriding the view template when rendering a component has been removed (eg. `ExampleComponent.call view: '<h1>Some overriden view</h1>'`)

### Added

- ERB compiled template caching in production

### Changed

- View rendering pipeline has been rewritten

### Fixed

- Nesting components has been fixed

## [1.1.1] - 2022-11-14

### Added

- Support for webpacker

## [1.1.0] - 2022-11-13

### Added

- StimulusJS controllers for components

## [1.0.0] - 2022-11-07

- Initial release
