+++
title = "Site Rework Part 1"
subtitle = "Reasoning and Goals"
date = "2018-04-07"
Description = ""
Tags = ["website", "Squarespace", "Hugo"]
Categories = ["website"]
[Author]
    name = "Vincent Kocks"
    description = "Game Programmer"
    emailAddress = "vincent@vingenuity.net"
    githubUsername = "vingenuity"
    twitterUsername = "kvingenuity"
    websiteAddress = "http://www.vingenuity.net"
+++

As mentioned in my previous post, I am going to be spending the next few weeks completely reworking the Vingenuity website.

In general, when redoing a previous project or tool, it's a good idea to think about what was positive and negative about the original, as well as do a little bit of advance planning. That's what today's post is about.

<!--more-->

{{% section class="section scrollspy" %}}
#### Old Site Postmortem

Previously, I used Squarespace to design this site. While I was satisfied overall with my experience with their website building tools, there were also a number of small to medium annoyances that have caused me to decide to try something else for the new site.

Here's a quick list:

##### Pros

1. **No scripting or special tooling is required to work on the site.**

	Squarespace has very slick WYSIWYG tools on their site, with drag-and-drop content modification that made it easy to adjust the site without writing any code. Additionally, since the tools were online, it was very easy to change the site using any computer. 

2. **Squarespace has beautiful-looking website templates.**

	I was always impressed by the variety and quality of the templates that were provided on Squarespace. While they lean more towards commercial and artist-centric templates, there were still a few different templates that I thought worked well for coding portfolios.

3. **Site templates were responsive and mobile-friendly.**

	In my opinion, the best feature of Squarespace's site designs is the fact that they are all responsive and work perfectly on mobile. Even for a portfolio site, having a solid mobile version is critical.

4. **Strong community and customer support.**

	There are quite a few companies that make Squarespace-specific code additions that work on most sites. Additionally, I always had good experiences with their support team.

##### Cons

1. **Squarespace is expensive.**

	In order to have the ability to add custom code to your site, a Squarespace business subscription is required, which runs $18 per month. For a portfolio site that will be dormant most of the time, this is a significant expense.

2. **Your content is locked into the service.**

	Since content is created using Squarespace's custom tools, it is very difficult to migrate content out of a Squarespace page. For the upcoming migration, I am planning on saving the pages as HTML files and rewriting them into another format by hand.

3. **Significant text and formatting repetition is required on similar pages.**

	If multiple pages are going to have similar layouts with different content (i.e. project pages), Squarespace doesn't have a great way of handling that. The best workflow I found was to duplicate a project page, then manually update the content. Due to this, I later found some copypasta errors on some of my project pages.

4. **It is very difficult to add functionality to sites.**

	If custom navigation or content display functionality is needed, the options in Squarespace are pretty limited. There are a few ways of injecting custom formatting or code in their base plan, but in order to fully customize the site with custom HTML, a more expensive plan is required.

5. **Squarespace sites are pretty heavyweight.**

	The beauty of Squarespace's pages has a cost -- they use multiple code frameworks to support the sites and tooling. Additionally, since all of the websites are dynamic, this incurs further loading cost.
{{% /section %}}
{{% section class="section scrollspy" %}}
#### New Site Goals

From the pros and cons above, I have set a few goals that I would like the new site to meet:

1. **Minimize expense.**

	As recent events have shown me, having a portfolio site ready to go at all times is extremely important. However, since it is likely that this site will be idle a significant portion of the time, I would like to minimize how much the site costs me to run each month.

2. **Use the DRY principle as much as possible.**

	In order to minimize typos, copypasta errors, and inconsistent information, I want to minimize amount of text that I need to duplicate between this site and my resume.

3. **Maintain responsiveness and mobile support.**

	Even though I'm moving away from pre-built sites, I would still like to maintain the responsive design of my previous site if possible. Mobile support is also a must.

4. **Keep the site minimal and fast.**

	Since mobile support is desired, site performance is a high priority. In addition to minimizing the code, I would also like to go with a more minimal theme as well.

5. **Make updating the site as simple as possible.**

	Using scripts (and possibly some CI tools later on), I would like to automate the process of updating and deploying the site as much as I can.
{{% /section %}}
{{% section class="section scrollspy" %}}
#### Frameworks and Tools

I have already chosen the frameworks and tools that I am going to be using to create the site. Here's the list so far:

1. **GitHub Pages**

	[GitHub](https://pages.github.com/) provides _free_ hosting for a single static website per user. Since I'm not planning on adding any dynamic functionality to my site, this seems like an ideal arrangement. Additionally, deployment via Git will allow for simpler automation with most CI tools.

2. **Hugo**

	For site creation, I am going to try using static websites with [Hugo](https://gohugo.io/). I had a tough time deciding between Jekyll and Hugo, but in the end I have decided to go with Hugo due to their Markdown extensions and shortcodes. Additionally, I have heard many good things about Go, and this will be a good intro to the language.

3. **Materialize CSS**

	I'm a big fan of Google's Material Design language, so I've decided to use that as the first theme of the new site. Of the frameworks I looked at, [Materialize CSS](http://materializecss.com) seems like the most complete as well as the easiest to use. Additionally, they have a number of components (cards, tabs, accordions) of which I would like to make use in the site.

4. **Pandoc**

	In order to minimize the amount of rewriting necessary when updating my resume, I am planning on using [Pandoc](https://pandoc.org/) to generate from a single source document all of the resume formats most companies request.

5. **PowerShell**

	When I worked on build systems at Robot, I used PowerShell as the primary scripting language. For this website, I see no reason to change. With the new [Powershell Core](https://github.com/PowerShell/PowerShell) update, my scripts will even be usable on Linux, which will make using CI tools much easier.
{{% /section %}}
{{% section class="section scrollspy" %}}
#### Conclusion

With these lists, I feel like I have the basis I need to determine whether this new site will meet my needs. Addionally, this list will be helpful when looking back at the new site design when the site is completed. All that's left now is to get my hands dirty and make the new site.

Until next time!
{{% /section %}}
