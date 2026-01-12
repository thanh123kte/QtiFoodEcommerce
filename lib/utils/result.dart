// lib/core/utils/result.dart
sealed class Result<T> {
  const Result();
  R when<R>({required R Function(T) ok, required R Function(String) err}) =>
      this is Ok<T> ? ok((this as Ok<T>).value) : err((this as Err<T>).message);
}
class Ok<T> extends Result<T> { final T value; const Ok(this.value); }
class Err<T> extends Result<T> { final String message; const Err(this.message); }
