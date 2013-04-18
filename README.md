makerbothackathon
=================

Thingiverse id/secret
-------------
To run locally, add copy .env.example to .env replacing the following variables with the id/secret to thingiverse app:
> TV_ID=your-id-here

> TV_SECRET=your-secret-here

then run: foreman start


Testing locally with sinatra and thingiverse
-------------
To test locally with thingiverse app, you can create a new app, and use the URL for your local setup, eg "http://localhost:5000/callback" etc.

You will need to set the client ID/Secret in your local setup to reflect the thingiverse app you're testing against.
