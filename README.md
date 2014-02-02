# OrmAdapter::Cequel

A plugin for [OrmAdapter](https://github.com/ianwhite/orm_adapter) adding
support for the [Cequel](https://github.com/cequel/cequel) Cassandra ORM.

## Usage

The primary audience of this library is library developers who want a
consistent interface to various ORMs. You probably don't need to add this to
your application directly.

## Supported features

This adapter supports all OrmAdapter features except for the `:order` and
`:offset` options for the `#find_first` and `#find_every` methods.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
