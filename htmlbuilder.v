module htmlbuilder

import strings
import os

const(
	// specifies whether a tag needs a corresponding closing tag
	// i.e. <div></div> vs <br>
	tag_does_auto_close = {
		"a":			false
		"abbr":			false
		"address":		false
		"area":			true
		"article":		false
		"aside":		false
		"audio":		false
		"b":			false
		"base":			true		// Didn't know this HTML tag existed. It's now my favorite lol
		"bdi":			false
		"bdo":			false
		"blockquote":	false
		"body":			false
		"br":			true
		"button":		false
		"canvas":		false
		"caption":		false
		"cite":			false
		"code":			false
		"col":			false
		"colgroup":		false
		"data":			false
		"datalist":		false
		"dd":			false
		"del":			false
		"details":		false
		"dfn":			false
		"dialog":		false
		"div":			false
		"dl":			false
		"dt":			false
		"em":			false
		"embed":		true
		"fieldset":		false
		"figcaption":	false
		"figure":		false
		"footer":		false
		"form":			false
		"h1":			false
		"h2":			false
		"h3":			false
		"h4":			false
		"h5":			false
		"h6":			false
		"head":			false
		"header":		false
		"hr":			true
		"html":			false
		"i":			false
		"iframe":		false
		"img":			true
		"input":		true
		"ins":			false
		"kbd":			false
		"label":		false
		"legend":		false
		"li":			false
		"link":			true
		"main":			false
		"map":			false
		"mark":			false
		"meta":			true
		"meter":		false
		"nav":			false
		"noscript":		false
		"object":		false
		"ol":			false
		"optgroup":		false
		"option":		false
		"output":		false
		"p":			false
		"param":		true
		"picutre":		false
		"pre":			false
		"progress":		false
		"q":			false
		"rp":			false
		"rt":			false
		"ruby":			false
		"s":			false
		"samp":			false
		"script":		false
		"section":		false
		"select":		false
		"small":		false
		"source":		true
		"span":			false
		"strong":		false
		"style":		false
		"sub":			false
		"summary":		false
		"sup":			false
		"svg":			false
		"table":		false
		"tbody":		false
		"td":			false
		"template":		false
		"textarea":		false
		"tfoot":		false
		"th":			false
		"thead":		false
		"time":			false
		"title":		false
		"tr":			false
		"track":		true
		"u":			false
		"ul":			false
		"var":			false
		"video":		false
		"wbr":			true
	}
)

/*
HTMLBuilder is an extenseion of string.Builder which
is targeted towards creating an HTML document in V
*/
pub struct HTMLBuilder {
mut:
	sb strings.Builder
	tags_to_be_closed []string = []string{}
	indent_level u16
}

/*
Attribute is an name and value which charactarize an HTML tag.
*/
pub struct Attribute {
__global:
	name string
	content string
}

/*
new_builder creates a new instances of Builder.
*/
pub fn new_builder() HTMLBuilder {
	return {
		sb: strings.new_builder(0)
	}
}

/*
open_tag creates an opening HTML tag based on inputs
*/
pub fn (mut hb HTMLBuilder) open_tag(tag string, attributes ...Attribute) {
	mut tag_bldr := strings.new_builder(0)
	// todo: auto indentation '\t'.repeat(tags2beclose.len)
	tag_bldr.write_string('<$tag')
	for attr in attributes {
		tag_bldr.write_string(' $attr.name')
		if attr.content.len > 0 {
			tag_bldr.write_string('="$attr.content"')
		}
	}
	tag_bldr.write_string('>')

	hb.sb.writeln('\t'.repeat(hb.indent_level) + tag_bldr.str())

	if !tag_does_auto_close[tag] {
		hb.tags_to_be_closed << tag
		hb.indent_level++
	}
}

/*
close_all_tags closes all tags that have been opened using open_tag
*/
pub fn (mut hb HTMLBuilder) close_all_tags() []string {
	return hb.close_tags(hb.tags_to_be_closed.len)
}

/*
close_tags closes n number of tags that have been opened using open_tag
*/
pub fn (mut hb HTMLBuilder) close_tags(n int) []string {
	tags_reversed := hb.tags_to_be_closed.reverse()[0..n]
	mut ret_tags := []string{}
	for _ in tags_reversed {
		ret_tags << hb.close_tag() or {return ret_tags}
	}

	return ret_tags
}

/*
close_tag closes the last tag that was opened using open_tag
*/
pub fn (mut hb HTMLBuilder) close_tag() ?string {
	if hb.tags_to_be_closed.len == 0 {
		return none
	}

	tag := hb.tags_to_be_closed.pop()
	hb.indent_level -= 1
	hb.sb.writeln('\t'.repeat(hb.indent_level) + '</$tag>')
	
	return tag
}

/*
write_comment creates an HTML comment with specified text inside
*/
pub fn (mut hb HTMLBuilder) write_comment(s string) {
	hb.writeln('<!-- $s -->')
}

/*
save_index appends the contents of HTMLBuilder to 'index.html'
then returns how many bytes were written
*/
pub fn (mut hb HTMLBuilder) save_index() ?int {
	return hb.save('index.html')
}

/*
save appends the contents of HTMLBuilder to specified file, then
returns how many bytes were written
*/
pub fn (mut hb HTMLBuilder) save(path string) ?int {
	mut file := os.open_append(path) or {
		return err
	}
	defer {
		file.close()
	}

	bytes_written := file.write_string(hb.str()) or {
		return err
	}

	return bytes_written
}

/*
pop returns a copy of all of the accumulate buffer content
*/
pub fn (mut hb HTMLBuilder) pop() string {
	return hb.sb.str()
}

/*
str returns a copy of all of the accumulated buffer content,
but does not empty the buffer.
*/
pub fn (mut hb HTMLBuilder) str() string {
	// have to do it funky like this because .str() empties buffer
	// and the builder can't be used anymore according to the docs
	/*	"after a call to b.str(), the builder b should not be used
		again, you need to call b.free() first, or just leave it to be
		freed by -autofree when it goes out of scope. The returned
		string owns its own separate copy of the accumulated data that
		was in the string builder, before the .str() call."
	*/
	str := hb.sb.str()
	hb.sb = strings.new_builder(0)
	hb.write_string(str)
	return str
}

///// string.Builder functions /////

/*
write_bytes appends bytes to the accumulated buffer [deprecated: 'use Builder.write_ptr() instead']

pub fn (mut hb HTMLBuilder) write_bytes(bytes byteptr, len int) {
	hb.sb.write_bytes(bytes, len)
}
*/

/*
write_ptr writes len bytes provided byteptr to the accumulated buffer.
*/
[unsafe]
pub fn (mut hb HTMLBuilder) write_ptr(ptr byteptr, len int) {
	hb.sb.write_string('\t'.repeat(hb.indent_level))
	unsafe {
		hb.sb.write_ptr(ptr, len)
	}
}

/*
write_b appends a single data byte to the accumulated buffer.
*/
pub fn (mut hb HTMLBuilder) write_b(data byte) {
	hb.sb.write_string('\t'.repeat(hb.indent_level))
	hb.sb.write_b(data)
}

/*
write implements the Writer interface.
*/
pub fn (mut hb HTMLBuilder) write(data []byte) ?int {
	hb.sb.write_string('\t'.repeat(hb.indent_level))
	return hb.sb.write(data)
}

/*
write appends the string s to the buffer.
*/
pub fn (mut hb HTMLBuilder) write_string(s string) {
	hb.sb.write_string('\t'.repeat(hb.indent_level))
	hb.sb.write_string(s)
}

/*
go_back discards the last n bytes from the buffer.
*/
pub fn (mut hb HTMLBuilder) go_back(n int) {
	hb.sb.go_back(n)
}

/*
cut_last cuts the last n bytes from the buffer and returns them.
*/
pub fn (mut hb HTMLBuilder) cut_last(n int) string {
	return hb.sb.cut_last(n)
}

/*
go_back_to resets the buffer to the given position pos
NB: pos should be < than the existing buffer length.
*/
pub fn (mut hb HTMLBuilder) go_back_to(pos int) {
	hb.sb.go_back_to(pos)
}

/*
writeln appends the string s, then a newline character.
*/
pub fn (mut hb HTMLBuilder) writeln(s string) {
	hb.sb.write_string('\t'.repeat(hb.indent_level))
	hb.sb.writeln(s)
}

/*
buf == 'hello world' last_n(5) returns 'world'.
*/
pub fn (mut hb HTMLBuilder) last_n(n int) string {
	return hb.sb.last_n(n)
}

/*
uf == 'hello world' after(6) returns 'world'.
*/
pub fn (mut hb HTMLBuilder) after(n int) string {
	return hb.sb.after(n)
}

/*
free manually frees the contents of the buffer.
*/
[unsafe]
pub fn (mut hb HTMLBuilder) free() {
	unsafe {
		hb.sb.free()
	}
}