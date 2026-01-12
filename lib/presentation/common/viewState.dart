sealed class ViewState { const ViewState(); }
class Idle extends ViewState { const Idle(); }
class Loading extends ViewState { const Loading(); }
class ErrorState extends ViewState { final String message; const ErrorState(this.message); }
class Success<T> extends ViewState { final T data; const Success(this.data); }
