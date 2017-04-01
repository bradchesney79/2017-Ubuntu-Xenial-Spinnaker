# 2017-Ubuntu-Xenial-Spinnaker
A local install of Spinnaker for streamlining deployment to cloud hosting

## Here are the main pages that have driven this install script.

https://github.com/spinnaker/spinnaker

https://github.com/spinnaker/deck

## Great, what is it for?

http://techblog.netflix.com/2016/03/how-we-build-code-at-netflix.html

## Why did you make some of the choices you did?

While deploying to the cloud is great-- I think running locally would be best for two reasons.

The first reason is that it needs resources, 8GB of RAM seems okay. Those hardware requirements kind of drive costs. At that cost I can buy brand new, powerful hardware and still be ahead in costs within a year.
So cost would be the second reason.

For anyone using this system, the deployment machines going down is a major inconvenience. They are generally not mission critical. We can get new parts and reinstall by the time we would "NEED TO GET THESE FEATURES PUSHED".

## Does it work?

No.

I think I need to modify a config file and possibly do some reverse proxying.
I've begun reaching out feelers to see if I can tap some advice from Netflix engineering.
