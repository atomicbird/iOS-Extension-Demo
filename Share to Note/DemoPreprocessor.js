var MyPreprocessor = function() {};

MyPreprocessor.prototype = {
    run: function(arguments) {
        arguments.completionFunction({"URL": document.URL, "pageSource": document.documentElement.outerHTML, "title": document.title, "selection": window.getSelection().toString()});
    }
};

var ExtensionPreprocessingJS = new MyPreprocessor;
