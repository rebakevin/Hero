/// Turns a stored photo path into a displayable URL. Pure lookup, so widgets may use it.
abstract interface class PhotoUrlResolver {
  String urlFor(String path);
}
