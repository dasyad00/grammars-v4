/*
 BSD License

 Copyright (c) 2023, Danang Syady Rahmatullah, Martin Mirchev. All rights reserved.

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

lexer grammar rtfLexer;

options {
	superClass = RtfLexerBase;
}

// This grammar does not care about ranges for some properties, namely: CONTROL_CODE_DELIMITER.

///// Header
RTFVERSION: '\\rtf' INTEGER? SPACE?;

// charset
ANSI: '\\ansi' SPACE?;
MAC: '\\mac' SPACE?;
PC: '\\pc' SPACE?;
PCA: '\\pca' SPACE?;
ANSICPG: '\\ansicpg' INTEGER;

// Default font
FROMTEXT: '\\fromtext' SPACE?;
FROMHTML: '\\fromhtml' SPACE?;

DEFFN: '\\deff' INTEGER SPACE?;
ADEFFN: '\\adeff' INTEGER SPACE?;
STSHFDBCHN: '\\stshfdbch' INTEGER SPACE?;
STSHFLOCHN: '\\stshfloch' INTEGER SPACE?;
STSHFHICHN: '\\stshfhich' INTEGER SPACE?;
STSHFBIN: '\\stshfbi' INTEGER SPACE?;

/// Font Table
FONTTBL: '\\fonttbl';

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

NONTAGGEDNAME: IGNORABLE_CONTROL_PREFIX '\\fname' SPACE?;
FONTEMB: IGNORABLE_CONTROL_PREFIX '\\fontemb' SPACE?;
FTNIL: '\\ftnil' SPACE?;
FTTRUETYPE: '\\fttruetype' SPACE?;
FONTFILE: IGNORABLE_CONTROL_PREFIX '\\fontfile' SPACE?;
CODEPAGE: '\\cpg' SPACE?;
FALT: IGNORABLE_CONTROL_PREFIX '\\falt' SPACE?;

/// Color Table
COLORTBL: '\\colortbl' SPACE?;

REDN: '\\red' INTEGER255;
GREENN: '\\green' INTEGER255;
BLUEN: '\\blue' INTEGER255;

/// Stylesheet
STYLESHEET: '\\stylesheet' SPACE?;
S: '\\s' SPACE?;
CS: IGNORABLE_CONTROL_PREFIX '\\cs' SPACE?;
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

/// List table
LIST: '\\list' SPACE?;
LISTTABLE: IGNORABLE_CONTROL_PREFIX '\\listtable' SPACE?;
LISTPICTURE: '\\listpicture' SPACE?;
LISTTEMPLATEIDN: '\\listtemplateid' INTEGER SPACE?;
LISTSIMPLE: '\\listsimple' SPACE?;
LISTHYBRID: '\\listhybrid' SPACE?;
LISTRESTARTHDNN: '\\listrestarthdn' INTEGER SPACE?;
LISTIDN: '\\listid' INTEGER SPACE?;
LISTNAME: '\\listname' SPACE?;
LISTSTYLEIDN: '\\liststyleid' INTEGER SPACE?;
LISTSTYLENAME: '\\liststylename' SPACE?;
LISTLEVEL: '\\listlevel' SPACE?;
LEVELFOLLOWN: '\\levelfollow' INTEGER SPACE?;
LEVELSTARTATN: '\\levelstartat' INTEGER SPACE?;
LVLTENTATIVE: '\\lvltentative' SPACE?;
LEVELOLDN: '\\levelold' INTEGER SPACE?;
LEVELPREVN: '\\levelprev' INTEGER SPACE?;
LEVELPREVSPACEN: '\\levelprevspace' INTEGER SPACE?;
LEVELSPACEN: '\\levelspace' INTEGER SPACE?;
LEVELINDENTN: '\\levelindent' INTEGER SPACE?;
LEVELTEXT: '\\leveltext' SPACE?;
LEVELTEMPLATEIDN: '\\leveltemplateid' INTEGER SPACE?;
LEVELNUMBERS: '\\levelnumbers' SPACE?;
LEVELLEGALN: '\\levellegal' INTEGER SPACE?;
LEVELNORESTARTN: '\\levelnorestart' INTEGER SPACE?;
LEVELPICTUREN: '\\levelpicture' INTEGER SPACE?;
JCLISTTAB: '\\jclisttab' SPACE?;
TXN: '\\tx' INTEGER SPACE?;
LEVELNFCN: '\\levelnfc' INTEGER SPACE?;
LEVELNFCNN: '\\levelnfcn' INTEGER SPACE?;
LEVELJCN: '\\leveljc' INTEGER SPACE?;
LEVELJCNN: '\\leveljcn' INTEGER SPACE?;

// List Override table
LISTOVERRIDETABLE: IGNORABLE_CONTROL_PREFIX '\\listoverridetable' SPACE?;
LISTOVERRIDE: '\\listoverride' SPACE?;
LISTOVERRIDECOUNTN: '\\listoverridecount' INTEGER SPACE?;
LISTOVERRIDESTARTAT: '\\listoverridestartat' SPACE?;
LISTOVERRIDEFORMATN: '\\listoverrideformat' INTEGER SPACE?;
LSN: '\\ls' INTEGER SPACE?;

GENERATOR: IGNORABLE_CONTROL_PREFIX '\\generator' SPACE?;

///// Document
INFO: '\\info' SPACE?;

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

/// user-defined document properties
USERPROPS: IGNORABLE_CONTROL_PREFIX '\\userprops' SPACE?;
PROPTYPEN: '\\proptype' INTEGER SPACE?;
PROPNAME: '\\propname' SPACE?;
STATICVAL: '\\staticval' SPACE?;
LINKVAL: '\\linkval' SPACE?;

//// Document formatting
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
PGNCHOSUNG: '\\pgnchosung' SPACE?;
PGNCNUM: '\\pgncnum' SPACE?;
PGNDBNUM: '\\pgndbnum' SPACE?;
PGNDBNUMD: '\\pgndbnumd' SPACE?;
PGNDBNUMT: '\\pgndbnumt' SPACE?;
PGNDBNUMK: '\\pgndbnumk' SPACE?;
PGNDECD: '\\pgndecd' SPACE?;
PGNGANADA: '\\pgnganada' SPACE?;
PGNGBNUM: '\\pgngbnum' SPACE?;
PGNGBNUMD: '\\pgngbnumd' SPACE?;
PGNGBNUML: '\\pgngbnuml' SPACE?;
PGNGBNUMK: '\\pgngbnumk' SPACE?;
PGNZODIAC: '\\pgnzodiac' SPACE?;
PGNZODIACD: '\\pgnzodiacd' SPACE?;
PGNZODIACL: '\\pgnzodiacl' SPACE?;
PGNHNN: '\\pgnhn' INTEGER SPACE?;
PGNHNSH: '\\pgnhnsh' SPACE?;
PGNHNSP: '\\pgnhnsp' SPACE?;
PGNHNSC: '\\pgnhnsc' SPACE?;
PGNHNSM: '\\pgnhnsm' SPACE?;
PGNHNSN: '\\pgnhnsn' SPACE?;
// footnotes and endnotes
SAFTNNALC: '\\saftnnalc' SPACE?;
SAFTNNAR: '\\saftnnar' SPACE?;
SAFTNNAUC: '\\saftnnauc' SPACE?;
SAFTNNRLC: '\\saftnnrlc' SPACE?;
SFTNBJ: '\\sftnbj' SPACE?;
SFTNNAR: '\\sftnnar' SPACE?;
SFTNNRLC: '\\sftnnrlc' SPACE?;

// Header Footer
HEADER: '\\header' SPACE?;
FOOTER: '\\footer' SPACE?;
HEADERL: '\\headerl' SPACE?;
HEADERR: '\\headerr' SPACE?;
HEADERF: '\\headerf' SPACE?;
FOOTERL: '\\footerl' SPACE?;
FOOTERR: '\\footerr' SPACE?;
FOOTERF: '\\footerf' SPACE?;

/// Paragraph text

// Paragraph formatting properties
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
FIN: '\\fi' '-'? INTEGER SPACE?;
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

// Tabs
TB: '\\tb' SPACE?;
TQR: '\\tqr' SPACE?;
TQC: '\\tqc' SPACE?;
TQDEC: '\\tqdec' SPACE?;
TLDOT: '\\tldot' SPACE?;
TLMDOT: '\\tlmdot' SPACE?;
TLHYPH: '\\tlhyph' SPACE?;
TLUL: '\\tlul' SPACE?;
TLTH: '\\tlth' SPACE?;
TLEQ: '\\tleq' SPACE?;

/// Bullets and Numbering
PNTEXT: '\\pntext' SPACE?;
PN: IGNORABLE_CONTROL_PREFIX '\\pn' SPACE?;
PNLVLN: '\\pnlvl' INTEGER SPACE?;
PNLVLBLT: '\\pnlvlblt' SPACE?;
PNLVLBODY: '\\pnlvlbody' SPACE?;
PNLVLCONT: '\\pnlvlcont' SPACE?;
PNSECLVL: '\\pnseclvl' SPACE?;
PNCARD: '\\pncard' SPACE?;
PNDEC: '\\pndec' SPACE?;
PNUCLTR: '\\pnucltr' SPACE?;
PNUCRM: '\\pnucrm' SPACE?;
PNLCLTR: '\\pnlcltr' SPACE?;
PNLCRM: '\\pnlcrm' SPACE?;
PNORD: '\\pnord' SPACE?;
PNORDT: '\\pnordt' SPACE?;
PNBIDIA: '\\pnbidia' SPACE?;
PNBIDIB: '\\pnbidib' SPACE?;
PNAIU: '\\pnaiu' SPACE?;
PNAIUD: '\\pnaiud' SPACE?;
PNAIUEO: '\\pnaiueo' SPACE?;
PNAIUEOD: '\\pnaiueod' SPACE?;
PNCHOSUNG: '\\pnchosung' SPACE?;
PNCNUM: '\\pncnum' SPACE?;
PNDBNUM: '\\pndbnum' SPACE?;
PNDBNUMD: '\\pndbnumd' SPACE?;
PNDBNUMK: '\\pndbnumk' SPACE?;
PNDBNUML: '\\pndbnuml' SPACE?;
PNDBNUMT: '\\pndbnumt' SPACE?;
PNDECD: '\\pndecd' SPACE?;
PNGANADA: '\\pnganada' SPACE?;
PNGBNUM: '\\pngbnum' SPACE?;
PNGBNUMD: '\\pngbnumd' SPACE?;
PNGBNUMK: '\\pngbnumk' SPACE?;
PNGBNUML: '\\pngbnuml' SPACE?;
PNIROHA: '\\pniroha' SPACE?;
PNIROHAD: '\\pnirohad' SPACE?;
PNULDASH: '\\pnuldash' SPACE?;
PNULDASHD: '\\pnuldashd' SPACE?;
PNULDASHDD: '\\pnuldashdd' SPACE?;
PNULHAIR: '\\pnulhair' SPACE?;
PNULTH: '\\pnulth' SPACE?;
PNULWAVE: '\\pnulwave' SPACE?;
PNZODIAC: '\\pnzodiac' SPACE?;
PNZODIACD: '\\pnzodiacd' SPACE?;
PNZODIACL: '\\pnzodiacl;' SPACE?;

PNSTARTN: '\\pnstart' INTEGER SPACE?;
PNNUMONCE: '\\pnnumonce' SPACE?;
PNACROSS: '\\pnacross' SPACE?;
PNINDENT: '\\pnindent' SPACE?;
PNSPN: '\\pnsp' INTEGER SPACE?;
PNPREV: '\\pnprev' SPACE?;
PNHANG: '\\pnhang' SPACE?;
PNRESTART: '\\pnrestart' SPACE?;

PNFN: '\\pnf' INTEGER SPACE?;
PNFSN: '\\pnfs' INTEGER SPACE?;
PNB: '\\pnb' SPACE?;
PNI: '\\pni' SPACE?;
PNCAPS: '\\pncaps' SPACE?;
PNSCAPS: '\\pnscaps' SPACE?;
PNUL: '\\pnul' SPACE?;
PNULD: '\\pnuld' SPACE?;
PNULDB: '\\pnuldb' SPACE?;
PNULNONE: '\\pnulnone' SPACE?;
PNULW: '\\pnulw' SPACE?;
PNSTRIKE: '\\pnstrike' SPACE?;
PNCFN: '\\pncf' INTEGER SPACE?;

PNQC: '\\pnqc' SPACE?;
PNQL: '\\pnql' SPACE?;
PNQR: '\\pnqr' SPACE?;

PNTXTB: '\\pntxtb' SPACE?;
PNTXTA: '\\pntxta' SPACE?;

/// Table definition
ROW: '\\row' SPACE?;
CELL: '\\cell' SPACE?;
TROWD: '\\TROWD' SPACE?;
TRGAPH: '\\trgaph' SPACE?;
NESTROW: '\\nestrow' SPACE?;
NESTCELL: '\\nestcell' SPACE?;
NESTTABLEPROPS:
	IGNORABLE_CONTROL_PREFIX '\\nesttableprops' SPACE?;

/// Character text
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

/// Highlighting
HIGHLIGHTN: '\\highlight' INTEGER SPACE?;

/// Special characters!
CHDATE: '\\chdate' SPACE?;
CHDPL: '\\chdpl' SPACE?;
CHDPA: '\\chdpa' SPACE?;
CHTIME: '\\chtime' SPACE?;
CHPGN: '\\chpgn' SPACE?;
SECTNUM: '\\sectnum' SPACE?;
CHFTN: '\\chftn' SPACE?;
CHATN: '\\chatn' SPACE?;
CHFTNSEP: '\\chftnsep' SPACE?;
CHFTNSEPC: '\\chftnsepc' SPACE?;
PAGE: '\\page' SPACE?;
COLUMN: '\\column' SPACE?;
LINE: '\\line' SPACE?;
LBRN: '\\lbr' INTEGER? SPACE?;
SOFTPAGE: '\\softpage' SPACE?;
SOFTCOL: '\\softcol' SPACE?;
SOFTLINE: '\\softline' SPACE?;
SOFTLHEIGHTN: '\\softlheight' INTEGER SPACE?;
TAB: '\\tab' SPACE?;
EMDASH: '\\emdash' SPACE?;
ENDASH: '\\endash' SPACE?;
EMSPACE: '\\emspace' SPACE?;
ENSPACE: '\\enspace' SPACE?;
QMSPACE: '\\qmspace' SPACE?;
BULLET: '\\bullet' SPACE?;
LQUOTE: '\\lquote' SPACE?;
RQUOTE: '\\rquote' SPACE?;
LDBLQUOTE: '\\ldblquote' SPACE?;
RDBLQUOTE: '\\rdblquote' SPACE?;
FORMULA: '\\|' SPACE?;
NBSP: '\\~' SPACE?;
OPTIONAL_HYPHEN: '\\-' SPACE?;
NONBREAKING_HYPHEN: '\\_' SPACE?;
SUBENTRY: '\\:' SPACE?;
IGNORABLE_CONTROL_PREFIX: '\\*';
ZWBO: '\\zwbo' SPACE?;
ZWNBO: '\\zwnbo' SPACE?;
ZWJ: '\\zwj' SPACE?;
ZWNJ: '\\zwnj' SPACE?;

// Lexer rules
WS: ('\\n' | '\u0000' | ('\r'? '\n') | '\r') -> skip;

SPACE: ' '+;

DOT: '.';
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
HEX_NUMBER: '\\\'' HEX_DIGIT HEX_DIGIT;

fragment HEX_DIGIT: [a-fA-F0-9];
fragment DIGIT: [0-9];

ESCAPED_OPENING_BRACE: '\\{';
ESCAPED_CLOSING_BRACE: '\\}';
ESCAPED_BACKSLASH: '\\\\';
OPENING_BRACE: '{';
CLOSING_BRACE: '}';
TEXT: ~([{}\\;])+;

PGDSCTBL: IGNORABLE_CONTROL_PREFIX '\\pgdsctbl' SPACE?;
CONTROL_CODE: '\\' [a-zA-Z]+ ((HYPHEN? INTEGER)? SPACE?)?;

UNKNOWN_CONTROL_GROUP:
	(
		OPENING_BRACE UNKNOWN_CONTROL_WORD { this.openingBrace(); this.pushMode(UnknownControl); }
	) -> skip;

UNKNOWN_CONTROL_WORD: PGDSCTBL;

ANY: .;

mode UnknownControl;

UNKNOWN_OPENING_BRACE: '{' { this.openingBrace();} -> skip;
UNKNOWN_CLOSING_BRACE: '}' { this.closingBrace();} -> skip;
INNER_CONTENT: ~[{}]+ -> skip;
