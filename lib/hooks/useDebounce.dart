import 'dart:async';
import 'package:flutter_hooks/flutter_hooks.dart';

String useDebounce(String value, Duration delay) {
  final debouncedValue = useState(value);

  useEffect(() {
    final timer = Timer(delay, () {
      debouncedValue.value = value;
    });

    return () => timer.cancel();
  }, [value, delay]);

  return debouncedValue.value;
}
