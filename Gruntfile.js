module.exports = function(grunt){
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-testem');
    grunt.loadNpmTasks('grunt-contrib-connect');

    grunt.initConfig({
        connect: {
            server: {
                options: {
                    port: 9006,
                    base: './'
                }
            }
        },
        testem: {
            options : {
                launch_in_dev : ['Chrome']
            },
            main : {
                src: [ 'tests/*.coffee' ]
            }
        },
        coffee:{
            compileJoined: {
                options: {
                    join: true
                },
                files: {
                    'js/painter.js': [
                        'coffee/util.coffee',
                        'coffee/msgpass.coffee',
                        'coffee/base.coffee',
                        'coffee/mutable.coffee',
                        'coffee/brush.coffee',
                        'coffee/painter.coffee',
                        'coffee/renderer.coffee',
                        'coffee/loop.coffee',
                    ],
                    'js/ui.js': [
                        'coffee/ui.coffee'
                    ],
                    'js/test.js': [
                        'coffee/util.coffee',
                        'coffee/base.coffee',
                        'coffee/mutable.coffee',
                        'coffee/transformation.coffee',
                        'tests/*.coffee',
                    ],
                    'js/msgpass.js': [
                        'coffee/msgpass.coffee',
                    ],
                }
            },
        },
        watch: {
            coffee: {
                files: ['coffee/*.coffee', 'tests/*.coffee'],
                tasks: 'coffee'
            }
        }
    });
    grunt.registerTask('default',[
        'coffee', 'connect', 'watch'
    ]);
}
