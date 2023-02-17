/*
 BSD License

 Copyright (c) 2023, Danang Syady Rahmatullah, Martin Mirchev All rights reserved.

 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer. 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution. 3. Neither the name of Tom Everett nor the names of its
 contributors may be used to endorse or promote products derived from this software without specific
 prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

grammar rtf;

// This grammar does not care about ranges for some properties, namely: CONTROL_CODE_DELIMITER.

// file: '{' header document '}' EOF;

header: rtfVersion charset deff? fonttbl colortbl;

rtfVersion: '\\rtf' INTEGER?;

charset: '\\ansi' | '\\mac' | '\\pc' | '\\pca';

// default font
deff: '\\deff' INTEGER;

/// Font Table

fonttbl: '{' '\\fonttbl' ( fontinfo | ('{' fontinfo '}')) '}';

// fontinfo: fontnum fontfamily fcharset? fprq? panose? nontaggedname? fontemb? codepage? fontname fontaltname? ';';
fontinfo: fontnum fontfamily fcharset? fontname SEMICOLON;

fontnum: '\\f' INTEGER;

fontfamily:
	'\\fnil'
	| '\\froman'
	| '\\fswiss'
	| '\\fmodern'
	| '\\fscript'
	| '\\fdecor'
	| '\\ftech'
	| '\\fbidi';

fcharset: '\\fcharset' INTEGER;

fontname: pcdata;

pcdata: ~ (CONTROL_CODE | SEMICOLON) | SEMICOLON??;

/// Color Table

colortbl : '{' '\\colortbl' colordef+ '}';

colordef: REDN? GREENN? BLUEN? SEMICOLON;

REDN: '\\red' INTEGER255;
GREENN: '\\green' INTEGER255;
BLUEN: '\\blue' INTEGER255;


// Lexer rules

CONTROL_CODE: '\\' [a-zA-Z]+ CONTROL_CODE_DELIMITER;

CONTROL_CODE_DELIMITER: (HYPHEN? DIGIT)? SPACE;

SPACE: ' '+;

HYPHEN: '-';
SEMICOLON: ';';

fragment INTEGER255:
	DIGIT
	| ('1' .. '9') DIGIT
	| '1' DIGIT DIGIT
	| '2' ('0' .. '4') DIGIT
	| '2' '5' ('0' .. '5');

INTEGER: DIGIT+;

fragment DIGIT: ('0' .. '9');

