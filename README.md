# 'I Want My MVC' Framework
This is a convention over configuration MVC framework built in Ruby that accomplishes CRUD functions.

#### You can see a working demo [here](https://i-want-my-mvc.herokuapp.com).

## Models

Rails ActiveRecord style class methods are provided—`all`, `find`, `where`—as well as associative class methods—`has_many`, `belongs_to`. As this is convention over configuration, set up your models in app/models, and have them inherit from ModelBase:

```ruby
require_relative '../../lib/model_base'

class YourModel < ModelBase
  make_column_attr_accessors!
end
```

`make_column_attr_accessors!` is required, as this triggers metaprogramming to create the getter and setter methods based on the model's table's schema, and these are required to interact with the database, and manipulate the models.

## Controllers/Views

This uses Ruby ERB templates. Again, as this is convention over configuration (gotta love it), put your views into app/views/[controller_name], and the controller action will automatically render the template with the same name, e.g. `index.html.erb`. There's even a handy `redirect_to` method that you can use instead of the automatic rendering.

```ruby
class MyController <ControllerBase
  def index
    redirect_to('/')
    #if you so fancy
  end
end
```

## Routes

Routes are placed in bin/server. To set up a route, define the HTTP verb, a regex expression to match the route, the target controller, and the action to run, e.g.:

```ruby
get Regexp.new('^/posts/\d+$'), PostsController, :show
```

## Params

A `Params` class decodes URL-encoded form data, as well as parameters stored in the request body, and stores it in a convenient `params` getter method, accessible in the controller.

```ruby
def post_params
  {
    :title => params['post']['title'],
    :body => params['post']['body']
  }
end
```

## `belongs_to` and `has_many`

There's some magic here: the convention I've made is to store the foreign key as `"#{associated_model}_id"`. So all you have to do is put in the model is `belongs_to :post`, for example. However, you can over ride the defaults and put in your own `foreign_key` or `class_name`, if you'd like.

```ruby
class YourModel < ModelBase
  belongs_to :another_model, :class_name => :something
  make_column_attr_accessors!
end
```