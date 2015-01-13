
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.afterSave("Beer", function(request) {
  // Our "Comment" class has a "text" key with the body of the comment itself
  // var commentText = request.object.get('text');

  var debitor = request.object.get('debitor');
  debitor.fetch({
    success: function(debitor) {
      var alertText = debitor.get('profile').name + ' owes you a new beer!';
     
      var pushQuery = new Parse.Query(Parse.Installation);
      pushQuery.equalTo('deviceType', 'ios');
      pushQuery.equalTo('user', request.object.get('creditor'));
        
      Parse.Push.send({
        where: pushQuery, // Set our Installation query
        data: {
          alert: alertText
        }
      }, {
        success: function() {
          // Push was successful
        },
        error: function(error) {
          throw "Got an error " + error.code + " : " + error.message;
        }
      });
    }
  });

});