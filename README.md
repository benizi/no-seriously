# No, Seriously

I'm looking for work in or near Pittsburgh, PA, USA.

## Credentials

I hate résumés, but [I nonetheless have a résumé](http://benizi.com/résumé.pdf).
It's best viewed as an introduction to my [Languages and Technologies page](http://benizi.com/tech),
which describes in much greater detail my background in and opinions of the
various languages and environments mentioned in my résumé.

## What is this?

In my last week of working at [4moms](http://4moms.com/), a fellow developer
told me someone had drawn a picture with their GitHub commit history.

That sounded kind of cute, but it also made me realize that my 2,160 commits to
the private repos in the [4moms GitHub organization](https://github.com/4moms)
were about to vanish from my profile, leaving it not desolate, but much
thinner.

I never saw the original execution (intentionally, at this point), so maybe I'm
just a copycat, but I figured I'd try it anyway.

## How does it work?

Git has a wonderful tool called [fast-import](https://www.kernel.org/pub/software/scm/git/docs/git-fast-import.html),
which is designed to import a repository from an external source.
The [fast-import input format](https://www.kernel.org/pub/software/scm/git/docs/git-fast-import.html#_input_format)
is well-documented and easy to create.  I'd used it in the past to import from
CVS (Gentoo) and Mercurial (Vim) repositories. (Now I use git-hg for Vim work.)

[git-headline.rb](git-headline.rb) simply creates a series of commits with the
right metadata which can be imported using `git fast-import`.

Full steps:

First: ensure there's at least one commit on the branch you're modifying.

```sh
EMAIL={desired-email-for-commits} ruby git-headline.rb | git fast-import
```
