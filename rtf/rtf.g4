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
	RTFVERSION charset UNICODE_CHAR_LEN? HTMAUTSP? from? deffont? // mandatory from v1.9
	(deflang | NOUICOMPAT)* // `deflang` mandatory from v1.9, order with `NOUICOMPAT` may vary
	fonttbl? colortbl? stylesheet?;

RTFVERSION: '\\rtf' INTEGER? SPACE?;

charset: (ANSI | MAC | PC | PCA)? (ANSICPG)?;
ANSI: '\\ansi' SPACE?;
MAC: '\\mac' SPACE?;
PC: '\\pc' SPACE?;
PCA: '\\pca' SPACE?;
ANSICPG: '\\ansicpg' INTEGER;

// Default font
from: FROMTEXT | FROMHTML;
FROMTEXT: '\\fromtext' SPACE?;
FROMHTML: '\\fromhtml' SPACE?;

// prevent matching empty string
deffont: (DEFFN | ADEFFN)+ (
		STSHFDBCHN STSHFLOCHN STSHFHICHN STSHFBIN
	)?;
DEFFN: '\\deff' INTEGER SPACE?;
ADEFFN: '\\adeff' INTEGER SPACE?;
STSHFDBCHN: '\\stshfdbch' INTEGER SPACE?;
STSHFLOCHN: '\\stshfloch' INTEGER SPACE?;
STSHFHICHN: '\\stshfhich' INTEGER SPACE?;
STSHFBIN: '\\stshfbi' INTEGER SPACE?;

// prevent matching empty string
deflang: (DEFLANGN | DEFLANGFEN | ADEFLANGN)+;

/// Font Table

fonttbl: '{' FONTTBL ( fontinfo | ('{' fontinfo '}'))+ '}';
FONTTBL: '\\fonttbl';

// edge cases: some documents exclude fontfamily hence it is defined as optional; fcharsetN and fprqN may be switched around in ordering.
fontinfo:
	FN fontfamily? ((FCHARSETN | FPRQN)+)? NONTAGGEDNAME? fontemb? CODEPAGE? fontname fontaltname?
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
FPRQN: '\\fprq' [012] SPACE?;

// TODO define PANOSE

fontemb:
	'{' FONTEMB fonttype (fontfname | data | fontfname data) '}';
fonttype: FTNIL | FTTRUETYPE;
fontfname: '{' FONTFILE CODEPAGE? pcdata '}';
fontname: pcdata;
fontaltname: '{' FALT pcdata '}';

NONTAGGEDNAME: IGNORABLE_CONTROL_PREFIX '\\fname' SPACE?;
FONTEMB: IGNORABLE_CONTROL_PREFIX '\\fontemb' SPACE?;
FTNIL: '\\ftnil' SPACE?;
FTTRUETYPE: '\\fttruetype' SPACE?;
FONTFILE: IGNORABLE_CONTROL_PREFIX '\\fontfile' SPACE?;
CODEPAGE: '\\cpg' SPACE?;
FALT: IGNORABLE_CONTROL_PREFIX '\\falt';

/// Color Table

colortbl: '{' COLORTBL colordef+ '}';
COLORTBL: '\\colortbl' SPACE?;

colordef: REDN? GREENN? BLUEN? SEMICOLON;

REDN: '\\red' INTEGER255;
GREENN: '\\green' INTEGER255;
BLUEN: '\\blue' INTEGER255;

/// Stylesheet
stylesheet: '{' STYLESHEET style+ '}';
style:
	'{' styledef? keycode? formatting additive? based? next? formatting?
	// libreoffice place `formattting` after `next`
	autoupd? hidden? personal? compose? reply? stylename? SEMICOLON '}';
styledef: S | CS | DS;
keycode: '{' KEYCODE keys '}';
keys: (SHIFT | CTRL | ALT)+ key;
key: FNN | pcdata;
additive: ADDITIVE;
based: SBASEDON;
next: SNEXTN;
autoupd: SAUTOUPD;
hidden: SHIDDEN;
personal: SPERSONAL;
compose: SCOMPOSE;
reply: SREPLY;

STYLESHEET: '\\stylesheet' SPACE?;
S: '\\s' SPACE?;
CS: '\\*\\cs' SPACE?;
DS: '\\ds' SPACE?;
KEYCODE: '\\keycode' SPACE?;
SHIFT: '\\shift' SPACE?;
CTRL: '\\ctrl' SPACE?;
ALT: '\\alt' SPACE?;
FNN: '\\fn' INTEGER? SPACE?;
ADDITIVE: '\\additive' SPACE?;
SBASEDON: '\\sbasedon' INTEGER? SPACE?;
SNEXTN: '\\snext' INTEGER? SPACE?;
SAUTOUPD: '\\sautoupd' SPACE?;
SHIDDEN: '\\shidden' SPACE?;
SPERSONAL: '\\spersonal' SPACE?;
SCOMPOSE: '\\scompose' SPACE?;
SREPLY: '\\sreply' SPACE?;
formatting: (
		// brdrdef
		parfmt
		// | apoctl |tabdef |shading
		| chrfmt
	)+;
stylename: pcdata;

///// Document

document: documentInfo? docfmt* section+;

// TODO add other fields
documentInfo:
	'{' INFO (
		title
		| subject
		| author
		| manager
		| company
		| operator
		| category
		| keywords
		| comment
		| VERSIONN
		| doccomm
		| VERNN
		| creatim
		| revtim
		| printim
		| buptim
		| EDMINS
		| NOFPAGESN
		| NOFWORDSN
		| NOFCHARSN
		| NOFCHARSWSN
		| IDN
	)* '}';
INFO: '\\info' SPACE?;

title: '{' TITLE pcdata '}';
subject: '{' SUBJECT pcdata '}';
author: '{' AUTHOR pcdata '}';
manager: '{' MANAGER pcdata '}';
company: '{' COMPANY pcdata '}';
operator: '{' OPERATOR pcdata '}';
category: '{' CATEGORY pcdata '}';
keywords: '{' KEYWORDS pcdata '}';
comment: '{' COMMENT pcdata '}';
doccomm: '{' DOCCOMM pcdata '}';
hlinkbase: '{' HLINKBASE pcdata '}';
creatim: '{' CREATIM time '}';
revtim: '{' REVTIM time '}';
printim: '{' PRINTIM time '}';
buptim: '{' BUPTIM time '}';
time: YRN? MON? DYN? HRN? MINN? SECN?;

VERSIONN: '\\version' INTEGER SPACE?;
VERNN: '\\vern' INTEGER SPACE?;
EDMINS: '\\edmins' INTEGER SPACE?;
NOFPAGESN: '\\nofpages' INTEGER SPACE?;
NOFWORDSN: '\\nofwords' INTEGER SPACE?;
NOFCHARSN: '\\nofchars' INTEGER SPACE?;
NOFCHARSWSN: '\\nofcharsws' INTEGER SPACE?;
IDN: '\\id' INTEGER SPACE?;

TITLE: '\\title' SPACE?;
SUBJECT: '\\subject' SPACE?;
AUTHOR: '\\author' SPACE?;
MANAGER: '\\manager' SPACE?;
COMPANY: '\\company' SPACE?;
OPERATOR: '\\operator' SPACE?;
CATEGORY: '\\category' SPACE?;
KEYWORDS: '\\keywords' SPACE?;
COMMENT: '\\comment' SPACE?;
DOCCOMM: '\\doccomm' SPACE?;
HLINKBASE: '\\hlinkbase' SPACE?;
CREATIM: '\\creatim' SPACE?;
REVTIM: '\\revtim' SPACE?;
PRINTIM: '\\printim' SPACE?;
BUPTIM: '\\buptim' SPACE?;

YRN: '\\yr' INTEGER SPACE?;
MON: '\\mo' INTEGER SPACE?;
DYN: '\\dy' INTEGER SPACE?;
HRN: '\\hr' INTEGER SPACE?;
MINN: '\\min' INTEGER SPACE?;
SECN: '\\sec' INTEGER SPACE?;

// TODO add other formatting fields
docfmt:
	DEFTABN
	| HYPHHOTZN
	| HYPHCONSECN
	| HYPHCAPS
	| HYPHAUTO
	| DEFLANGN
	| DEFLANGFEN
	| ADEFLANGN
	| DOCTYPEN
	// document views
	| VIEWKINDN
	| VIEWSCALEN
	// footnotes and endnotes
	| FETN
	| FTNSEP
	| FTNSEPC
	| FTNCN
	| AFTNSEP
	| AFTNSEPC
	| AFTNCN
	| ENDNOTES
	| ENDDOC
	| FTNTJ
	| FTNBJ
	| AENDNOTES
	| AENDDOC
	| AFTNBJ
	| AFTNTJ
	| FTNSTARTN
	| AFTNSTARTN
	| FTNRSTPG
	| FTNRESTART
	| FTNRSTCONT
	| AFTNRESTART
	| AFTNRSTCONT
	| FTNNAR
	| FTNNALC
	| FTNNAUC
	| FTNNRLC
	| FTNNRUC
	| FTNNCHI
	| FTNNCHOSUNG
	| FTNNCNUM
	| FTNNDBNUM
	| FTNNDBNUMD
	| FTNNDBNUMT
	| FTNNDBNUMK
	| FTNNDBAR
	| FTNNGANADA
	| FTNNGBNUM
	| FTNNGBNUMD
	| FTNNGBNUML
	| FTNNGBNUMK
	| FTNNZODIAC
	| FTNNZODIACD
	| FTNNZODIACL
	| AFTNNAR
	| AFTNNALC
	| AFTNNAUC
	| AFTNNRLC
	| AFTNNRUC
	| AFTNNCHI
	| AFTNNCHOSUN
	| AFTNNCNUM
	// TODO add remaining footnote numberings

	// page information
	| PAPERWN
	| PAPERHN
	| MARGLN
	| MARGRN
	| MARGTN
	| MARGBN
	| HTMAUTSP
	// other?
	| NOUICOMPAT
	| FORMSHADE;
DEFTABN: '\\deftab' INTEGER SPACE?;
HYPHHOTZN: '\\hyphhotz' INTEGER SPACE?;
HYPHCONSECN: '\\hyphconsec' INTEGER SPACE?;
HYPHCAPS: '\\hyphcaps' SPACE?;
HYPHAUTO: '\\hyphauto' [01] SPACE?;

DEFLANGN: '\\deflang' INTEGER SPACE?;
DEFLANGFEN: '\\deflangfe' INTEGER SPACE?;
ADEFLANGN: '\\adeflang' INTEGER SPACE?;
DOCTYPEN: '\\doctype' INTEGER SPACE?;
/// Document views
VIEWKINDN: '\\viewkind' INTEGER SPACE?;
VIEWSCALEN: '\\viewscale' INTEGER SPACE?;
// footnotes and endnotes
FETN: '\\fet' INTEGER SPACE?;
FTNSEP: '\\ftnsep' SPACE?;
FTNSEPC: '\\ftnsepc' SPACE?;
FTNCN: '\\ftncn' SPACE?;
AFTNSEP: '\\aftnsep' SPACE?;
AFTNSEPC: '\\aftnsepc' SPACE?;
AFTNCN: '\\aftncn' SPACE?;
ENDNOTES: '\\endnotes' SPACE?;
ENDDOC: '\\enddoc' SPACE?;
FTNTJ: '\\ftntj' SPACE?;
FTNBJ: '\\ftnbj' SPACE?;
AENDNOTES: '\\aendnotes' SPACE?;
AENDDOC: '\\aenddoc' SPACE?;
AFTNBJ: '\\aftnbj' SPACE?;
AFTNTJ: '\\aftntj' SPACE?;
FTNSTARTN: '\\ftnstart' INTEGER SPACE?;
AFTNSTARTN: '\\aftnstart' INTEGER SPACE?;
FTNRSTPG: '\\ftnrstpg' SPACE?;
FTNRESTART: '\\ftnrestart' SPACE?;
FTNRSTCONT: '\\ftnrstcont' SPACE?;
AFTNRESTART: '\\aftnrestart' SPACE?;
AFTNRSTCONT: '\\aftnrstcont' SPACE?;
FTNNAR: '\\ftnnar' SPACE?;
FTNNALC: '\\ftnnalc' SPACE?;
FTNNAUC: '\\ftnnauc' SPACE?;
FTNNRLC: '\\ftnnrlc' SPACE?;
FTNNRUC: '\\ftnnruc' SPACE?;
FTNNCHI: '\\ftnnchi' SPACE?;
FTNNCHOSUNG: '\\ftnnchosung' SPACE?;
FTNNCNUM: '\\ftnncnum' SPACE?;
FTNNDBNUM: '\\ftnndbnum' SPACE?;
FTNNDBNUMD: '\\ftnndbnumd' SPACE?;
FTNNDBNUMT: '\\ftnndbnumt' SPACE?;
FTNNDBNUMK: '\\ftnndbnumk' SPACE?;
FTNNDBAR: '\\ftnndbar' SPACE?;
FTNNGANADA: '\\ftnnganada' SPACE?;
FTNNGBNUM: '\\ftnngbnum' SPACE?;
FTNNGBNUMD: '\\ftnngbnumd' SPACE?;
FTNNGBNUML: '\\ftnngbnuml' SPACE?;
FTNNGBNUMK: '\\ftnngbnumk' SPACE?;
FTNNZODIAC: '\\ftnnzodiac' SPACE?;
FTNNZODIACD: '\\ftnnzodiacd' SPACE?;
FTNNZODIACL: '\\ftnnzodiacl' SPACE?;
AFTNNAR: '\\aftnnar' SPACE?;
AFTNNALC: '\\aftnnalc' SPACE?;
AFTNNAUC: '\\aftnnauc' SPACE?;
AFTNNRLC: '\\aftnnrlc' SPACE?;
AFTNNRUC: '\\aftnnruc' SPACE?;
AFTNNCHI: '\\aftnnchi' SPACE?;
AFTNNCHOSUN: '\\aftnnchosun' SPACE?;
AFTNNCNUM: '\\aftnncnum' SPACE?;
/// Page information Margins
PAPERWN: '\\paperw' INTEGER SPACE?;
PAPERHN: '\\paperh' INTEGER SPACE?;
MARGLN: '\\margl' INTEGER SPACE?;
MARGRN: '\\margr' INTEGER SPACE?;
MARGTN: '\\margt' INTEGER SPACE?;
MARGBN: '\\margb' INTEGER SPACE?;
HTMAUTSP: '\\htmautsp' SPACE?;
NOUICOMPAT: '\\nouicompat' SPACE?;
// forms
FORMSHADE: '\\formshade' SPACE?;

/// Section
section: secfmt* hdrftr? para+ ( SECT section)?;

secfmt: // These control words can appear anywhere in the section.
	SECT
	| SECTD
	| ENDNHERE
	| BINFSXNN
	| BINSXNN
	| DS
	| PNSECLVLN
	| SECTUNLOCKED
	// section break
	| SBKNONE
	| SBKCOL
	| SBKPAGE
	| SBKEVEN
	| SBKODD
	// columns
	| COLSN
	| COLSXN
	| COLNON
	| COLSRN
	| COLWN
	| LINEBETCOL
	// line numbering
	| LINEMODN
	| LINEXN
	| LINESTARTSN
	| LINERESTART
	| LINEPPAGE
	| LINECONT
	// page information
	| PGWSXNN
	| PGHSXNN
	| MARGLSXNN
	| MARGRSXNN
	| MARGTSXNN
	| MARGBSXNN
	| MARGMIRSXN
	| LNDSCPSXN
	// page numbers
	| PGNSTARTSN
	| PGNCONT
	| PGNRESTART
	| PGNXN
	| PGNYN
	| PGNDEC
	| PGNUCRM
	| PGNLCRM
	| PGNUCLTR
	| PGNLCLTR
	| PGNBIDIA
	| PGNBIDIB
	// TODO add remaining page number types TODO add remaining 2002 codes
	| SAFTNNALC
	| SAFTNNAR
	| SAFTNNAUC
	| SAFTNNRLC
	| SFTNBJ
	| SFTNNAR
	| SFTNNRLC;

SECT: '\\sect' SPACE?;
SECTD: '\\sectd' SPACE?;
ENDNHERE: '\\endnhere' SPACE?;
BINFSXNN: '\\binfsxn' INTEGER SPACE?;
BINSXNN: '\\binsxn' INTEGER SPACE?;
PNSECLVLN: '\\pnseclvl' INTEGER SPACE?;
SECTUNLOCKED: '\\sectunlocked' INTEGER? SPACE?;
// section break
SBKNONE: '\\sbknone' SPACE?;
SBKCOL: '\\sbknone' SPACE?;
SBKPAGE: '\\sbknone' SPACE?;
SBKEVEN: '\\sbknone' SPACE?;
SBKODD: '\\sbknone' SPACE?;
// columns
COLSN: '\\sbknone' INTEGER SPACE?;
COLSXN: '\\sbknone' INTEGER SPACE?;
COLNON: '\\sbknone' INTEGER SPACE?;
COLSRN: '\\sbknone' INTEGER SPACE?;
COLWN: '\\sbknone' INTEGER SPACE?;
LINEBETCOL: '\\sbknone' INTEGER SPACE?;
// line numbering
LINEMODN: '\\linemod' INTEGER SPACE?;
LINEXN: '\\linex' INTEGER SPACE?;
LINESTARTSN: '\\linestarts' INTEGER SPACE?;
LINERESTART: '\\linerestart' SPACE?;
LINEPPAGE: '\\lineppage' SPACE?;
LINECONT: '\\linecont' SPACE?;
// page information
PGWSXNN: '\\pgwsxn' INTEGER SPACE?;
PGHSXNN: '\\pghsxn' INTEGER SPACE?;
MARGLSXNN: '\\marglsxn' INTEGER SPACE?;
MARGRSXNN: '\\margrsxn' INTEGER SPACE?;
MARGTSXNN: '\\margtsxn' INTEGER SPACE?;
MARGBSXNN: '\\margbsxn' INTEGER SPACE?;
MARGMIRSXN: '\\margmirsxn' SPACE?;
LNDSCPSXN: '\\lndscpsxn' SPACE?;
// page numbers
PGNSTARTSN: '\\pgnstarts' INTEGER SPACE?;
PGNCONT: '\\pgncont' SPACE?;
PGNRESTART: '\\pgnrestart' SPACE?;
PGNXN: '\\pgnx' INTEGER SPACE?;
PGNYN: '\\pgny' INTEGER SPACE?;
PGNDEC: '\\pgndec' SPACE?;
PGNUCRM: '\\pgnucrm' SPACE?;
PGNLCRM: '\\pgnlcrm' SPACE?;
PGNUCLTR: '\\pgnucltr' SPACE?;
PGNLCLTR: '\\pgnlcltr' SPACE?;
PGNBIDIA: '\\pgnbidia' SPACE?;
PGNBIDIB: '\\pgnbidib' SPACE?;
SAFTNNALC: '\\saftnnalc' SPACE?;
SAFTNNAR: '\\saftnnar' SPACE?;
SAFTNNAUC: '\\saftnnauc' SPACE?;
SAFTNNRLC: '\\saftnnrlc' SPACE?;
SFTNBJ: '\\sftnbj' SPACE?;
SFTNNAR: '\\sftnnar' SPACE?;
SFTNNRLC: '\\sftnnrlc' SPACE?;

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
	| KEEP
	| KEEPN
	| NOLINE
	| HYPHPAR_TOGGLE
	| ITAPN
	| NOWIDCTLPAR
	| WIDCTLPAR
	| SN
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
	| SAAUTON
	| SBAUTON
	| SLN
	| SLMULTN
	// bidirectional controls
	| RTLPAR
	| LTRPAR;
PAR: '\\par' SPACE?;
PARD: '\\pard' SPACE?;
KEEP: '\\keep' SPACE?;
KEEPN: '\\keepn' SPACE?;
NOLINE: '\\noline' SPACE?;
HYPHPAR_TOGGLE: '\\hyphpar' [01] SPACE?;
ITAPN: '\\itap' INTEGER SPACE?;
NOWIDCTLPAR: '\\nowidctlpar' SPACE?;
WIDCTLPAR: '\\widctlpar' SPACE?;
SN: '\\s' INTEGER SPACE?;
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
SAAUTON: '\\saauto' INTEGER SPACE?;
SBAUTON: '\\sbauto' INTEGER SPACE?;
SLN: '\\sl' INTEGER SPACE?;
SLMULTN: '\\slmult' INTEGER SPACE?;
// subdocuments
SUBDOCUMENTN: '\\subdocument' INTEGER SPACE?;

/// Table definition
row: (tbldef cell+ tbldef ROW)
	| (tbldef cell+ ROW)
	| (cell+ tbldef ROW);
tbldef: TROWD TRGAPH; // TODO add remaining control words
cell: (nestrow? tbldef?) textpar+ CELL;
nestrow:
	nestcell+ '{' IGNORABLE_CONTROL_PREFIX NESTTABLEPROPS tbldef NESTROW '}';
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
	| CFN
	| CSN
	| FN
	| FSN
	| I0
	| KERNINGN
	| LANGFEN
	| LANGFENPN
	| LANGN
	| LANGNPN
	| ALANGN
	| LTRCH
	| RTLCH
	| OUTL0
	| SHAD0
	| STRIKE0
	| STRIKED10
	| SUB
	| SUPER
	| UL0
	| aprops;
PLAIN: '\\plain' SPACE?;
B0: '\\b' '0'? SPACE?;
CAPS0: '\\caps' '0'? SPACE?;
CBN: '\\cb' INTEGER SPACE?;
CFN: '\\cf' INTEGER SPACE?;
CSN: '\\cs' INTEGER SPACE?;
FN: '\\f' INTEGER SPACE?;
FSN: '\\fs' INTEGER SPACE?;
I0: '\\i' '0'? SPACE?;
KERNINGN: '\\kerning' INTEGER? SPACE?;
LANGFEN: '\\langfe' INTEGER SPACE?;
LANGFENPN: '\\langfenp' INTEGER SPACE?;
LANGN: '\\lang' INTEGER SPACE?;
LANGNPN: '\\langnp' INTEGER SPACE?;
ALANGN: '\\alang' INTEGER SPACE?;
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

aprops:
	RTLCH
	| LTRCH
	| AFN
	| AFSN
	| AI
	| LOCH
	| HICH
	| DBCH
	| RTLPAR
	| LTRPAR;

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
AFN: '\\af' INTEGER? SPACE?;
AFSN: '\\afs' INTEGER? SPACE?;
AI: '\\ai' SPACE?;
HICH: '\\hich' SPACE?;
LOCH: '\\loch' SPACE?;
DBCH: '\\dbch' SPACE?;
// Bidirectional Controls
RTLPAR: '\\rtlpar' SPACE?;
LTRPAR: '\\ltrpar' SPACE?;

/// Special characters!
spec:
	PAR
	| SECT
	| FORMULA
	| NBSP
	| OPTIONAL_HYPHEN
	| NONBREAKING_HYPHEN;
// | HEX_NUMBER;

FORMULA: '\\|' SPACE?;
NBSP: '\\~' SPACE?;
OPTIONAL_HYPHEN: '\\-' SPACE?;
NONBREAKING_HYPHEN: '\\_' SPACE?;
SUBENTRY: '\\:' SPACE?;
IGNORABLE_CONTROL_PREFIX: '\\*';

// Wrap `data` in braces (See Other problem areas in RTF: Property changes)
data: '{' data '}' | pcdata | spec; // TODO add rest of data

// taken from 'Formal Syntax' section
pcdata: (
		~(
			'{'
			| '}'
			// undefined control codes
			| CONTROL_CODE
			// rtf
			| RTFVERSION
			// `charset`
			| ANSI
			| MAC
			| PC
			| PCA
			| ANSICPG
			// default font
			| DEFFN
			| ADEFFN
			//  `fonttbl`
			| FN
			| FONTTBL
			// `fontfamily
			| FNIL
			| FROMAN
			| FSWISS
			| FMODERN
			| FSCRIPT
			| FDECOR
			| FTECH
			| FBIDI
			| FCHARSETN
			| FPRQN
			| NONTAGGEDNAME
			|
			// `fontemb`
			NONTAGGEDNAME
			| FONTEMB
			| FTNIL
			| FTTRUETYPE
			| FONTFILE
			| CODEPAGE
			| FALT
			// stylesheet
			| STYLESHEET
			| S
			| CS
			| DS
			| KEYCODE
			| SHIFT
			| CTRL
			| ALT
			| FNN
			| ADDITIVE
			| SBASEDON
			| SNEXTN
			| SAUTOUPD
			| SHIDDEN
			| SPERSONAL
			| SCOMPOSE
			| SREPLY
			// Document info
			| INFO
			// `docfmt`
			| DEFTABN
			| HYPHHOTZN
			| HYPHCONSECN
			| HYPHCAPS
			| HYPHAUTO
			| DEFLANGN
			| DEFLANGFEN
			| ADEFLANGN
			| DOCTYPEN
			// document views and zoom level
			| VIEWKINDN
			| VIEWSCALEN
			// footnotes and endnotes
			| FETN
			| FTNSEP
			| FTNSEPC
			| FTNCN
			| AFTNSEP
			| AFTNSEPC
			| AFTNCN
			| ENDNOTES
			| ENDDOC
			| FTNTJ
			| FTNBJ
			| AENDNOTES
			| AENDDOC
			| AFTNBJ
			| AFTNTJ
			| FTNSTARTN
			| AFTNSTARTN
			| FTNRSTPG
			| FTNRESTART
			| FTNRSTCONT
			| AFTNRESTART
			| AFTNRSTCONT
			| FTNNAR
			| FTNNALC
			| FTNNAUC
			| FTNNRLC
			| FTNNRUC
			| FTNNCHI
			| FTNNCHOSUNG
			| FTNNCNUM
			| FTNNDBNUM
			| FTNNDBNUMD
			| FTNNDBNUMT
			| FTNNDBNUMK
			| FTNNDBAR
			| FTNNGANADA
			| FTNNGBNUM
			| FTNNGBNUMD
			| FTNNGBNUML
			| FTNNGBNUMK
			| FTNNZODIAC
			| FTNNZODIACD
			| FTNNZODIACL
			| AFTNNAR
			| AFTNNALC
			| AFTNNAUC
			| AFTNNRLC
			| AFTNNRUC
			| AFTNNCHI
			| AFTNNCHOSUN
			| AFTNNCNUM
			// page information
			| PAPERWN
			| PAPERHN
			| MARGLN
			| MARGRN
			| MARGTN
			| MARGBN
			| HTMAUTSP
			// other?
			| NOUICOMPAT
			| FORMSHADE
			//// `secfmt`
			| SECT
			| ENDNHERE
			| BINFSXNN
			| BINSXNN
			| DS
			| PNSECLVLN
			| SECTUNLOCKED
			// section break
			| SECTD
			| SBKNONE
			| SBKCOL
			| SBKPAGE
			| SBKEVEN
			| SBKODD
			| COLSN
			| COLSXN
			| COLNON
			| COLSRN
			| COLWN
			| LINEBETCOL
			// line numbering
			| LINEMODN
			| LINEXN
			| LINESTARTSN
			| LINERESTART
			| LINEPPAGE
			| LINECONT
			// page information
			| PGWSXNN
			| PGHSXNN
			| MARGLSXNN
			| MARGRSXNN
			| MARGTSXNN
			| MARGBSXNN
			| MARGMIRSXN
			| LNDSCPSXN
			// page numbers
			| PGNSTARTSN
			| PGNCONT
			| PGNRESTART
			| PGNXN
			| PGNYN
			| PGNDEC
			| PGNUCRM
			| PGNLCRM
			| PGNUCLTR
			| PGNLCLTR
			| PGNBIDIA
			| PGNBIDIB
			| SAFTNNALC
			| SAFTNNAR
			| SAFTNNAUC
			| SAFTNNRLC
			| SFTNBJ
			| SFTNNAR
			| SFTNNRLC
			//// `headerctl`
			| HEADER
			| FOOTER
			| HEADERL
			| HEADERR
			| HEADERF
			| FOOTERL
			| FOOTERR
			| FOOTERF
			| RTLCH
			| LTRCH
			| AFN
			| AFSN
			| AI
			// defined control codes `parfmt`
			| PAR
			| PARD
			| ITAPN
			| SN
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
			| CFN
			| CSN
			| FN
			| FSN
			| I0
			| KERNINGN
			| LANGFEN
			| LANGFENPN
			| LANGN
			| LANGNPN
			| ALANGN
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

WS: ('\\n' | '\u0000' | ('\r'? '\n') | '\r') -> skip;

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
UNKNOWN_CONTROL_GROUP:
	(
		'{' UNKNOWN_CONTROL_WORD (
			// ('{' (~('{' | '}') | CONTROL_CODE | ANY | SPACE | INTEGER)*? '}')* |
			(
				(
					~('{' | '}')
					| CONTROL_CODE
					| ANY
					| SPACE
					| INTEGER
				)*?
			)
		) '}'
	) -> skip;
// TODO nested unknowns UNKNOWN_CONTROL_GROUP: ( '{' UNKNOWN_CONTROL_WORD ( '{' (~'}' | ANY | SPACE
// | INTEGER)*? '}' | (~'}' | ANY | SPACE | INTEGER)+? )+ '}' ) ; INNER_UNKNOWN_CONTROL_GROUP: '{'
// INNER_UNKNOWN_CONTROL_GROUP '}' | (~'}' | ANY | SPACE | INTEGER)+; IGNORED_CONTROL_CODE:
// (IGNORABLE_CONTROL_PREFIX'\\' [a-zA-Z]+ ((HYPHEN? DIGIT)? SPACE?)) -> skip;
UNKNOWN_CONTROL_WORD: (
		IGNORABLE_CONTROL_PREFIX '\\' [a-zA-Z]+ (
			(HYPHEN? INTEGER)? SPACE?
		)
	);
CONTROL_CODE: '\\' [a-zA-Z]+ ((HYPHEN? INTEGER)? SPACE?)?;

ANY: .;
