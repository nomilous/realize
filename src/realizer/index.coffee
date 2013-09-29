modules = ['load', 'connect', 'run']
exports[mod] = require "./#{mod}" for mod in modules
