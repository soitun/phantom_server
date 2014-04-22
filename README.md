# phantom_server

## What is it?

phantom_server is a deploy-ready phantomjs cluster which will help you render
full HTML pages for your single-page web application.
It performs a similar role as other services like [Pre-Render](https://prerender.io/)

## Why should you?

If you're using single-page frameworks like AngularJS or EmberJS you must know
the major pains:
1. SEO - search engines do not render JS so they have to get a full version of
   the page in order to correctly index your site.
2. Caching - In order to cache full rendred pages in your local cache or CDN
   you have to be able to fully render them
3. Mobile Performance - Some older devices are having difficulties executing
   the JS involved in single-page applications.

## How phantom_server Resolves These Issues?

By rendering full HTML pages:
1. Search engines will receive a full HTML of your pages and won't have any
   trouble indexing it.
2. You will have fully rendered HTML pages in your local cache or CDN.
3. Since mobile devices will mainly get fully renderd pages they won't have to
   go through the hassle of rendering them themselves thus reducing the
   performance issues with single-page applications.

## How It Works?

1. Your server gets a request to /url
2. Your server requests phantom_server to render /url
3. phantom_server requests the single-page version of /url from your server
4. phantom_server renders the page
5. phantom_server returns the fully renderd page to your server
6. Your server responds with a fully rendred page

## Pre-Requisites

phantom_server is currently configured to work on AWS EC2.
This is the list of things needed to get it going:

An EC2 instance with the following:
  * tags:

  | Tag Name      | Tag Value   
  | ------------- | -------------
  | Project       | phantom_server
  | Env           | qa      
  | Roles         | web 

  * nginx installed
  * phantomjs installed
  * ruby, rubygems and bundler installed

## Get it started

1. Clone this repository to your machine
2. Fill in config/server.yml
3. run `cap qa deploy:setup deploy:cold`

That's it - You're supposed to have phantom server started!

## Client Side

phantom_server is intended to work with [phantom_renderer](https://github.com/FTBpro/phantom_renderer)
which runs on your server and performs the communication with the phantom server.



