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
                        'lib/app/util.coffee',
                        'lib/app/msgpass.coffee',
                        'lib/app/base.coffee',
                        'lib/app/mutable.coffee',
                        'lib/app/brush.coffee',
                        'lib/app/painter.coffee',
                        'lib/app/renderer.coffee',
                        'lib/app/loop.coffee'
                    ],
                    'js/ui.js': [
                        'lib/ui/ui.coffee'
                    ],
                    'js/gui-components.js': [
                        'lib/app/transformation.coffee',
                        'xtags/*.coffee'
                    ],
                    'js/test.js': [
                        'lib/app/util.coffee',
                        'lib/app/base.coffee',
                        'lib/app/mutable.coffee',
                        'lib/app/transformation.coffee',
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
                files: ['lib/app/*.coffee', 'lib/ui/*.coffee',  'xtags/*.coffee', 'tests/*.coffee'],
                tasks: 'coffee'
            }
        }
    });
    grunt.registerTask('default',[
        'coffee', 'connect', 'watch'
    ]);
};
