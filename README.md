# 'I Want My MVC' Framework
This is a convention-over-configuration web framework inspired by Ruby on Rails. It uses MVC architecture, and has an ORM thanks to metaprogramming.

I've deployed a very rudimentary site to Heroku that shows it supporting CRUD functions: [Demo](https://i-want-my-mvc.herokuapp.com).

## Models

Model classes will inherit from `ModelBase`, and go in `app/models`. Class methods `all`, `find`, `where`, `has_many`, and `belongs_to` are given:

```ruby
class Post < ModelBase
  belongs_to :user
  make_column_attr_accessors!
end

class PostsController < ControllerBase
  def index
    @posts = Post.all
  end
end
```

A couple notes: 

1. `make_column_attr_accessors!` must be called to trigger metaprogramming; an accessor will be made for each column in that model's table.

2. Use `belongs_to` and `has_many` to form associations with other models. If you're following convention, the name of the model is enough. But if there's a situation where you want a more semantic name, for example `post.author`, when `author` represents an instance of the `User` model, specify the class name:

```ruby
class Post < ModelBase
  belongs_to :author, :class_name => :user
  make_column_attr_accessors!
end
```

The same same flexibility is provided for `foreign_key`.

## Controllers

The `view` with the name of the controller action is implicitly rendered:


```ruby
class PostsController < ControllerBase
  def index
  end
end
```
This will render `app/views/posts_controller/index.html.erb`. 

But if you'd like to redirect instead, use `redirect_to`:

```ruby
class PostsController < ControllerBase
  def index
    redirect_to ('/')
  end
end
```

###Params
Key in to the `params` reader, for form data encoded into the request body and/or a query string:
```ruby

class MyController < ControllerBase
  def create
    @post = Post.new(post_params)
  end

  private

  def post_params
    {
      :title => params['post']['title'],
      :body => params['post']['body']
    }
  end
end
```

##Views

This framework uses ERB templates, and as mentioned above, are named and organized by the controller action (`app/views/posts_controller/index.html.erb`).


## Routes

Routes are placed in `bin/server`. To set up a route, define the HTTP verb, a regex expression to match the route, the target controller, and the action to run:

```ruby
router.draw do
  get Regexp.new('^/posts/\d+$'), PostsController, :show
end
```