path = require('path')
os = require('os')

sourcePath = 'src'
outputPath = 'bin'
codeDir    = 'js'

# inside bin/
devDir  = 'dev'
prodDir = 'prod'
tempDir = 'src'

devPath            = path.join(outputPath, devDir)
prodPath           = path.join(outputPath, prodDir)
tempPath           = path.join(outputPath, tempDir)
tempCodePath       = path.join(tempPath, codeDir)
codePath           = path.join(sourcePath, codeDir)
outputCodePath     = path.join(outputPath, codeDir)

coffeelintPath     = 'coffeelint.json'
gruntfilePath      = 'Gruntfile.coffee'

sourceResources = ['html/**', 'css/**', 'resources/**', 'deps/**', 'fonts/**']

module.exports = (grunt) ->
  fileMaps =
    browserify: {}
    uglify: {}

  codeFiles = grunt.file.expand {cwd: codePath, matchBase: true}, ['*.coffee']

  for file in codeFiles
    jsFile = file.replace('.coffee', '.js')
    browserfied = path.join(devPath, codeDir, jsFile)
    fileMaps.browserify[browserfied] = path.join(tempCodePath, jsFile)
    fileMaps.uglify[path.join(prodPath, codeDir, jsFile)] = browserfied

  # grunt-contrib-clean
  clean =
    all: [devPath, prodPath, tempPath]
    temp: [tempPath]

  # grunt-coffeelint
  coffeelint =
    src:
      files:
        src: ["#{sourcePath}/**/*.coffee"]
      options:
        configFile: coffeelintPath

  # grunt-contrib-coffee
  coffee =
    src:
      expand: true
      cwd: codePath
      src: ['**/*.coffee']
      dest: tempCodePath
      ext: '.js'

  # grunt-mkdir
  mkdir =
    unpacked:
      options:
        create: [devPath, prodPath]
    js:
      options:
        create: ["#{devPath}/#{codeDir}"]

  # grunt-contrib-copy
  copy =
    main:
      files: [ {
        expand: true
        cwd: sourcePath
        src: sourceResources
        dest: devPath
      } ]
    deps:
      files: [
        expand: true
        cwd: sourcePath
        src: ['deps/**']
        dest: tempPath
      ]
    prod:
      files: [ {
        # copy the dev directory minus compiled js to prevent code duplication
        expand: true
        cwd: devPath
        src: ['**', '!js/*.js']
        dest: prodPath
      }]

  # grunt-browserify
  browserify =
    build:
      files: fileMaps.browserify
      options:
        browserifyOptions:
          debug: true
          standalone: 'livedrop'

  # grunt-contrib-uglify
  uglify =
    min:
      files: fileMaps.uglify

  # grunt-contrib-watch
  watch =
    files: [gruntfilePath, "#{sourcePath}/**"]
    tasks: ['build']


  config = {clean, coffeelint, coffee, mkdir, copy, browserify, uglify, watch}
  grunt.initConfig(config)

  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-browserify')
  grunt.loadNpmTasks('grunt-mkdir')

  grunt.registerTask('build',
    ['clean:all', 'copy:deps', 'coffeelint', 'coffee', 'copy:main', 'mkdir:js', 'browserify'])

  grunt.registerTask('release', ['build', 'copy:prod', 'uglify'])

  grunt.registerTask('default', 'release')
