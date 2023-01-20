## The END
By the end of this video, we want to understand how to write a Phoenix Component. 

We will take example of an ecommerce site where we want to display the product price in red color with a specific font size. Assuming we use Tailwind css framework, the HTML would be like:

```html
<span class="text-red-600 text-lg">99.99 INR</span>
```

Instead of writing this HTML, we would like to write a Phoenix Component and use it in its place such as

```elixir
<.price>99.99 INR</.price>
```

Let's see how. 

1. First we will understand, what is a Phoenix Component and how to define it?
2. then, we will understand how to use it?
3. finally, we will understand why we need Phoenix Component and why certain features of the Phoenix component behave the way it does.


## What is a Phoenix Component?
Phoenix Component is a simple Elixir function, similar to any other functions that you define inside Elixir modules, that returns an HTML template written using `sigil_H`. That's not a complete definition. As they say "The Devil is in the details". Yes, Phoenix component is a simple Elixir function but it needs to meet the below conditions:

* This function should have an arity of 1
* The argument should always be named as `assigns`
* The return value of this function should be a template written using `~H` (`sigil_H`)

The `price` function defined inside `Product.Components` module qualifies as a Phoenix Component because it satisfies all the above three conditions: as it has only arity and that argument is named as `assigns` and the return value of the function is an HTML template written using `~H` (`sigil_H`).


```elixir 
defmodule Product.Components do
  def display_price(assigns) do
    ~H"""
    <span class="text-red-600 text-lg"><%= @price %></span>
    """
  end
end
```

But Why should be always keep the argument name as `assigns`? Why should the arity be always one? A simple and naive answer is that's how Phoenix requires you to write it. We will understand the reasoning behind it towards the end. For now, remember these three rules as the qualifying criteria for an Elixir function to be treated as Phoenix Component.

## How to use it?
You can use an Phoenix Component by calling the function name along with the module name like this:

```elixir
<Product.Components.display_price price="99.99 INR">
```

This should return the HTML

```html
<span class="red">99.99 INR</span>
```

However, one must admit that this doesn't look great or feel great as developer experience to write HTML tags like this. Ideally, I would like something like this:

```elixir
<.price>99.99 INR</.price>
```

where `@price` is preset to value of `99.99 INR`, to have it rendered like:

```html
<span class="red">99.99 INR</span>
```

Converting 
```elixir
<Product.Components.display_price price="99.99 INR">
```

to 

```elixir
<.price>99.99 INR</.price>
```

requires two things
1. We want to avoid using the module name while invoking the component
2. We want to pass on the content, i.e., `99.99 INR` as the inner text of the tag, rather than as an attribute of the tag.

Handling the first is simple, in the LiveView where this component is invoked, let's add an import statement which will help us get rid of the module name in our tags.

```elixir
import Product.Components 
```

now, we can just use `<.price price="99.99 INR" />`. Note the use `.` in the tag name. Without this `.`, Phoenix cannot determine if this is a Phoenix Component or a regular HTML tag that goes unprocessed. So if you see `<.table>` in your Phoenix project, somewhere someone has defined a functional Phoenix Component in the name of `table`, where as if you see `<table>`, it's plain old HTML table tag.

Now, let's move on to changing the price being an attribute to inner text of the tag. We can go ahead and code in our template as 

```elixir
<.price>99.99 INR</.price>
```

This will now throw an error because earlier we had `price` attribute on our tag which we referenced in our template as `@price` variable. However, since we don't have this attribute, the variable is undefined and hence the error. 

Phoenix Component provides another default variable for the inner text of the tag. This is called `@inner_block` and inside the template, it can be rendered using the function `render_slot` like:

```elixir 
defmodule Product.Components do
  def display_price(assigns) do
    ~H"""
    <span class="red">
      <%= render_slot(@inner_block) %>
    </span>
    """
  end
end
```

Now, if you visit the page again, you should see the price displayed properly without any errors and we have a clean HTML template with the new price tag `<.price>99.99 INR</.price>`. The feature that we just used now is called `slot`, while the earlier implementation used `attr` feature of Phoenix Component. We will dive into `attr and slot` in more detail in another video. For now, we just scratched the surface of using both attr and slot.

## Why do we need Phoenix Component?
Phoenix Component allows us to reuse HTML templates across multiple pages or sections in an application.

Imagine you are building an ecommerce website, you might have several pages or multiple sections within a page that requires you to display the price in a specific format. Let's say in red color in a specific font size represented by the HTML `<span class="red text-large">PRODUCT_PRICE INR</span>`. Instead of having to repeat this `span` tag along with those specific classes `red text-large` in all over your application, you can define this snippet as a functional Phoenix Component and use the function name as HTML tag which will then render the exact template. This has two advantages:

1. Obviously, we repeat less code.
2. If we decide to change the class name, add or remove, we can do it in one place and have it changed across multiple instances where it's invoked.

Is that cool? I believe so. Now, back to the questions that I promised to answer at the end. Why should you name the argument as only `assigns`?

Let's go back to our component definition:

```elixir 
defmodule Product.Components do
  def display_price(assigns) do
    ~H"""
    <span class="red">
      <%= render_slot(@inner_block) %>
    </span>
    """
  end
end
```

The first question is why should this function take only one argument. If I have a requirement to pass on multiple values to my functional component, how do I pass it? You can pass multiple values to your component and there is no limit on the number of values you pass to a component. Irrespective of whether you pass on a value as attribute or a slot, Phoenix Component internally merges all these into a single map with multiple key value pairs and then passes this map on the function as `assigns` variable.

This leads to our next question, why should we name the argument as `assigns` and not something else? Moreover, it looks like the variable `assigns` actually never got used. Nowhere in the body we use the variable `assigns`, but then why is it needed? That's because there is a magic happening behind the scene using Elixir macros to make our code look less verbose. Let's remove those magic to see why we need the variable `assigns`. Let's replace `@inner_block` with `Map.fetch(assigns, :inner_block)`. We get the same result but now with more code. In fact, `@inner_block` in the template actually invokes the same code `Map.fetch(assigns, :inner_block)` behind the scene. This is the macro magic that is used by Phoenix to reduce the code developers write and this also should explain why we actually need the argument to be called `assigns`. If we change the argument `assigns` to `something_else`, then the macro magic trigger by `@` will still look for the variable `assigns` and as it doesn't exists, this will throw an error. You can go ahead and change it for yourself and see what happens when you rename `assigns`. 

## What Next?
If you are watching GO (Gratitude Overflow) Videos for the first time, you might want to watch 
* "How are these videos structured? And why?" to understand the common pattern I use in my videos so you can understand the concepts in the videos better.
* "Everything is Premium" to understand why I create these videos and how you can be a part of it?
