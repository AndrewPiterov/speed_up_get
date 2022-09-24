abstract class IAsyncInitServiceParams {}

abstract class IAsyncInitService<T> {
  Future initAsync([IAsyncInitServiceParams? params]);
}
