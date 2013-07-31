module.exports = function(grunt){
    grunt.initConfig({
        glob_to_multiple: {
            expand: true,
            flatten: true,
            cwd: '.',
            src: ['./*.coffee'],
            dest: './js/',
            ext: '.js'
        }
    });
}
