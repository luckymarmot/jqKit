# jqKit

An Objective-C wrapper for jqlib, the C library behind [jq](https://stedolan.github.io/jq/) (a lightweight and flexible JSON processor).

⚠️ Works only on macOS 10.10+

## Installation

Via Cocoapods:

```shell
pod 'macOSjqKit'
```


## Usage

```objc
NSString* program = @"."; // the jq filter
NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"foo":@0, @"bar":@42} options:kNilOptions error:NULL];

// filter
NSArray<NSData*>* results = [LMJqFilter filterWithProgram:program data:jsonData error:NULL];

// enumerate the results
[results enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSLog(@"result = %@", [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding]);
}];
```

## Development

### Build `libjq` and `oniguruma`

```shell
make
```

### Influences

* [JQKit](https://github.com/fleitz/JQKit)
* [pyjq](https://github.com/doloopwhile/pyjq)

## License

Copyright 2019 Paw. MIT License.
