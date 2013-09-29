modules = ['configure', 'connect', 'run', 'error']
module.exports[mod] = require "./#{mod}" for mod in modules
