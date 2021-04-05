# v-htmlbuilder
 An extension of strings.Builder targeted for HTML development. It's nothing to special, I've just ended up using it more than a couple times. So, I thought I'd make it easily available.

## Example
```v
// instantiate new builder
mut hb := htmlbuilder.new_builder()
// this just writes strings like strings.Builder.writeln
hb.writeln('<!DOCTYPE html>')
// this will write '<html lang="en-US" dir="ltr">' and increase the tab count, so using
// open_tag again auto indents the next tag
hb.open_tag('html', {name: 'lang', content: 'en-US'}, {name: 'dir', content: 'ltr'})
// this will automatically close the last tag opened. Tags like <br>, <meta>, <link>, etc.
// will be skipped since they autoclose
hb.close_tag()  // writes '</html>' in this instance

// see the documentation for more information
```

## Installation
VPM - No, that's not a typo. VPM only allows package names of 10 character. Which means I couldn't finish the word 'builder'.
```bash
v install islonely.htmlbuilde
```
VPKG
```bash
vpkg get htmlbuilder
```
Git
```bash
git clone https://github.com/islonely/v-htmlbuilder ~/.vmodules/htmlbuilder
```

## Documentation
[IPFS gateway](https://gateway.ipfs.io/ipfs/bafybeieltriifqjpz5jvj52rlmz3ec2v3uzi5qyil3dzuli3ssnecq2a24/htmlbuilder.html)

(no way to create a link in GH markdown for ipfs:// as far as I'm aware)

### Donations
Pls, I'm broke lol

[![.NET Conf - November 10-12, 2020](https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png)](https://www.buymeacoffee.com/islonely)
