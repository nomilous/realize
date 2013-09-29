modules = ['configure', 'connect', 'run']
exports[mod] = require "./#{mod}" for mod in modules
