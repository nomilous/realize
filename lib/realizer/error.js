// Generated by CoffeeScript 1.6.3
module.exports = function(errno, code, message) {
  var error;
  error = new Error(message);
  error.errno = errno;
  error.code = code;
  return error;
};