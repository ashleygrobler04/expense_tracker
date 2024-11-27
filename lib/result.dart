class Result<T,E> {
  final bool isSuccess;
  final E? error;
  final T? value;

  const Result._(this.isSuccess,this.value,this.error);

  static Result<T,E> Error<T,E>(E? error) {
    return Result<T,E>._(false,null,error);
  }

  static Result<T,E> Success<T,E>(T value) {
    return Result<T,E>._(true,value,null);
  }
}
