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

file: '{' header document '}' EOF;

///// Header edge case: some documents contain \ucN and \htmautsp in the header
header:
	RTFVERSION charset UNICODE_CHAR_LEN? HTMAUTSP? DEFF? fonttbl colortbl;

RTFVERSION: RTF INTEGER?;
RTF: '\\rtf';

charset: (ANSI | MAC | PC | PCA)? (ANSICPG)?;
ANSI: '\\ansi' SPACE?;
MAC: '\\mac' SPACE?;
PC: '\\pc' SPACE?;
PCA: '\\pca' SPACE?;
ANSICPG: '\\ansicpg' INTEGER;
// default font
DEFF: '\\deff' INTEGER SPACE?;

/// Font Table

fonttbl: '{' FONTTBL ( fontinfo | ('{' fontinfo '}'))+ '}';
FONTTBL: '\\fonttbl';

// edge cases: SEMICOLON is optional because PCDATA captures semicolon; some documents exclude fontfamily hence it is defined as optional.
fontinfo:
	FN fontfamily? FCHARSETN? FPRQN? NONTAGGEDNAME? fontemb? CODEPAGE? fontname fontaltname?
		SEMICOLON;

fontfamily:
	FNIL
	| FROMAN
	| FSWISS
	| FMODERN
	| FSCRIPT
	| FDECOR
	| FTECH
	| FBIDI;
FNIL: '\\fnil' SPACE?;
FROMAN: '\\froman' SPACE?;
FSWISS: '\\fswiss' SPACE?;
FMODERN: '\\fmodern' SPACE?;
FSCRIPT: '\\fscript' SPACE?;
FDECOR: '\\fdecor' SPACE?;
FTECH: '\\ftech' SPACE?;
FBIDI: '\\fbidi' SPACE?;

FCHARSETN: '\\fcharset' INTEGER SPACE?;

// pitch of a font has 3 valid arguments
FPRQN: '\\fprq' ('0' | '1' | '2') SPACE?;

// TODO define PANOSE

fontemb:
	'{\\*' FONTEMB fonttype (fontfname | data | fontfname data) '}';
fonttype: FTNIL | FTTRUETYPE;
fontfname: '{\\*' FONTFILE CODEPAGE? pcdata '}';
fontname: pcdata;
fontaltname: '{\\*' '\\falt' pcdata '}';

NONTAGGEDNAME: '\\*' '\\fname' SPACE?;
FONTEMB: '\\fontemb' SPACE?;
FTNIL: '\\ftnil' SPACE?;
FTTRUETYPE: '\\fttruetype' SPACE?;
FONTFILE: '\\fontfile' SPACE?;
CODEPAGE: '\\cpg' SPACE?;

/// Color Table

colortbl: '{' COLORTBL colordef+ '}';
COLORTBL: '\\colortbl' SPACE?;

colordef: REDN? GREENN? BLUEN? SEMICOLON;

REDN: '\\red' INTEGER255;
GREENN: '\\green' INTEGER255;
BLUEN: '\\blue' INTEGER255;

///// Document

document: documentInfo? docfmt* section+;

// TODO add other fields
documentInfo: '{' title? '}';

title: '{' '\\title' pcdata '}';

// TODO add other formatting fields
docfmt: MARGLN | MARGRN | MARGTN | MARGBN | HTMAUTSP;

/// Page information Margins
MARGLN: '\\margl' INTEGER SPACE?;
MARGRN: '\\marrl' INTEGER SPACE?;
MARGTN: '\\martl' INTEGER SPACE?;
MARGBN: '\\marbl' INTEGER SPACE?;
HTMAUTSP: '\\htmautsp' SPACE?;

/// Section
section: secfmt* hdrftr? para+ ( '\\sect' section)?;

secfmt: // These control words can appear anywhere in the section.
	SECT;

hdrftr: '{' hdrctl para+ '}' hdrftr?;

hdrctl:
	HEADER
	| FOOTER
	| HEADERL
	| HEADERR
	| HEADERF
	| FOOTERL
	| FOOTERR
	| FOOTERF;

/// Paragraph text

// Wrap `para` in braces (See Other problem areas in RTF: Property changes)
para: '{' para '}' | textpar | row;

textpar: (parfmt | secfmt)* (SUBDOCUMENTN | charText+) (PAR para)?;
// Paragraph formatting properties
parfmt: // NOTE: These control words can appear anywhere in the body of a paragraph.
	PAR
	| PARD
	| ITAPN
	// alignment
	| QC
	| QJ
	| QL
	| QR
	| QD
	// indentation
	| FIN
	| CUFIN
	| LIN
	| LINN
	| RIN
	| RINN
	// spacing
	| SAN
	| SBN
	// bidirectional controls
	| RTLPAR
	| LTRPAR;
PAR: '\\par' SPACE?;
PARD: '\\pard' SPACE?;
ITAPN: '\\itap' INTEGER SPACE?;
// alignment
QC: '\\qc' SPACE?; // centered
QJ: '\\qj' SPACE?; // justified
QL: '\\ql' SPACE?; // left-aligned (default)
QR: '\\qr' SPACE?; // right-aligned
QD: '\\qd' SPACE?; // distributed
// indentation
FIN: '\\fi' INTEGER SPACE?;
CUFIN: '\\cufi' INTEGER SPACE?;
LIN: '\\li' INTEGER SPACE?;
LINN: '\\lin' INTEGER SPACE?;
RIN: '\\ri' INTEGER SPACE?;
RINN: '\\rin' INTEGER SPACE?;
// spacing
SAN: '\\sa' INTEGER SPACE?;
SBN: '\\sb' INTEGER SPACE?;
// subdocuments
SUBDOCUMENTN: '\\subdocument' INTEGER SPACE?;

/// Table definition
row: (tbldef cell+ tbldef ROW)
	| (tbldef cell+ ROW)
	| (cell+ tbldef ROW);
tbldef: TROWD TRGAPH; // TODO add remaining control words
cell: (nestrow? tbldef?) textpar+ CELL;
nestrow: nestcell+ '{\\*' NESTTABLEPROPS tbldef NESTROW '}';
nestcell: textpar+ NESTCELL;
ROW: '\\row' SPACE?;
CELL: '\\cell' SPACE?;
TROWD: '\\TROWD' SPACE?;
TRGAPH: '\\trgaph' SPACE?;
NESTROW: '\\nestrow' SPACE?;
NESTCELL: '\\nestcell' SPACE?;
NESTTABLEPROPS: '\\nesttableprops' SPACE?;

/// Character text
charText: '{' charText '}' | ptext | atext;
ptext: (
		((chrfmt | parfmt | secfmt)* data)
		// specification leads to left-recursion
		| ((chrfmt | parfmt | secfmt)+ charText)
	)+;

// token suffixed by 0 are formatting properties which be disabled.
chrfmt:
	PLAIN
	| B0
	| CAPS0
	| CBN
	| CSN
	| FN
	| FSN
	| I0
	| LANGN
	| LANGNPN
	| LTRCH
	| RTLCH
	| OUTL0
	| SHAD0
	| STRIKE0
	| STRIKED10
	| SUB
	| SUPER
	| UL0;
PLAIN: '\\plain' SPACE?;
B0: '\\b' '0'? SPACE?;
CAPS0: '\\caps' '0'? SPACE?;
CBN: '\\cb' INTEGER SPACE?;
CSN: '\\cs' INTEGER SPACE?;
FN: '\\f' INTEGER SPACE?;
FSN: '\\fs' INTEGER SPACE?;
I0: '\\i' '0'? SPACE?;
LANGN: '\\lang' INTEGER SPACE?;
LANGNPN: '\\langnp' INTEGER SPACE?;
OUTL0: '\\shad' '0'? SPACE?;
SHAD0: '\\shad' '0'? SPACE?;
STRIKE0: '\\strike' '0'? SPACE?;
STRIKED10: '\\striked1' '0'? SPACE?;
SUB: '\\sub' '0'? SPACE?;
SUPER: '\\super' '0'? SPACE?;
UL0: '\\ul' '0'? SPACE?;

// Associated Character Properties

atext: ltrrun | rtlrun | losbrun | hisbrun | dbrun;
// TODO investigate &
ltrrun: RTLCH aprops* LTRCH ptext;
rtlrun: LTRCH aprops* RTLCH ptext;
losbrun: HICH DBCH LOCH ptext;
hisbrun: LOCH DBCH HICH ptext;
dbrun: LOCH HICH DBCH ptext;

aprops: LOCH | HICH | DBCH | RTLPAR | LTRPAR;

SECT: '\\sect';

HEADER: '\\header' SPACE?;
FOOTER: '\\footer' SPACE?;
HEADERL: '\\headerl' SPACE?;
HEADERR: '\\headerr' SPACE?;
HEADERF: '\\headerf' SPACE?;
FOOTERL: '\\footerl' SPACE?;
FOOTERR: '\\footerr' SPACE?;
FOOTERF: '\\footerf' SPACE?;

RTLCH: '\\rtlch' SPACE?;
LTRCH: '\\ltrch' SPACE?;
AF: '\\af' SPACE?;
HICH: '\\hich' SPACE?;
LOCH: '\\loch' SPACE?;
DBCH: '\\dbch' SPACE?;
// Bidirectional Controls
RTLPAR: '\\rtlpar' SPACE?;
LTRPAR: '\\ltrpar' SPACE?;

/// Special characters!
spec:
	PAR
	| SECT; // TODO | FORMULA | NBSP | OPTIONAL_HYPHEN | NONBREAKING_HYPHEN | HEXVALUE;

// Wrap `data` in braces (See Other problem areas in RTF: Property changes)
data: '{' data '}' | pcdata | spec; // TODO add rest of data

// taken from 'Formal Syntax' section
pcdata: (
		~(
			'{'
			| '}'
			| CONTROL_CODE // undefined control codes
			// defined control codes `parfmt`
			| PAR
			| PARD
			| ITAPN
			| QC
			| QJ
			| QL
			| QR
			| QD
			| FIN
			| CUFIN
			| LIN
			| LINN
			| RIN
			| RINN
			| SAN
			| SBN
			| RTLPAR
			| LTRPAR
			// `chrfmt`
			| PLAIN
			| B0
			| CAPS0
			| CBN
			| CSN
			| FN
			| FSN
			| I0
			| LANGN
			| LANGNPN
			| LTRCH
			| RTLCH
			| OUTL0
			| SHAD0
			| STRIKE0
			| STRIKED10
			| SUB
			| SUPER
			| UL0
			// `aprops`
			| LOCH
			| HICH
			| DBCH
			| RTLPAR
			| LTRPAR
		)
		| '\\}'
		| '\\{'
		| '\\\\'
	)+;

// Lexer rules

WS: ('\\n' | ('\r'? '\n') | '\r') -> skip;

SPACE: ' '+;

HYPHEN: '-';
SEMICOLON: ';';

fragment INTEGER255:
	DIGIT
	| [1-9] DIGIT
	| '1' DIGIT DIGIT
	| '2' [0-4] DIGIT
	| '2' '5' [0-5];

UNICODE_CHAR: '\\u' INTEGER SPACE?;
UNICODE_CHAR_LEN: '\\uc' INTEGER SPACE?;

INTEGER: DIGIT+;
HEX_NUMBER: '\\\'h' HEX_DIGIT HEX_DIGIT;

fragment HEX_DIGIT: [a-fA-F0-9];
fragment DIGIT: [0-9];

CONTROL_CODE: '\\' [a-zA-Z]+ ((HYPHEN? DIGIT)? SPACE?)?;

ANY: .;
