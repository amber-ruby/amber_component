const registeredControllers = {}

export function eagerLoadAmberComponentControllers(application) {
  const paths = Object.keys(parseImportmapJson()).filter(path => path.match(new RegExp(`/controller$`)))
  paths.forEach(path => registerControllerFromPath(path, application))
}

function parseImportmapJson() {
  return JSON.parse(document.querySelector("script[type=importmap]").text).imports
}

function registerControllerFromPath(path, application) {
  const name = path
    .replace("/controller", "")
    .replace(/\//g, "--")
    .replace(/_/g, "-")

  if (!(name in registeredControllers)) {
    import(path)
      .then(module => registerController(name, module, application))
      .catch(error => console.error(`Failed to register controller: ${name} (${path})`, error))
  }
}

function registerController(name, module, application) {
  if (!(name in registeredControllers)) {
    application.register(name, module.default)
    registeredControllers[name] = true
  }
}
