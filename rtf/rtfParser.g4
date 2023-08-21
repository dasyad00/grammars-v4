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

parser grammar rtfParser;
options {
	tokenVocab = rtfLexer;
}

file: OPENING_BRACE header document CLOSING_BRACE EOF;

///// Header edge case: some documents contain \ucN and \htmautsp in the header
header:
	RTFVERSION charset UNICODE_CHAR_LEN? HTMAUTSP? from? deffont? // mandatory from v1.9
	(deflang | NOUICOMPAT)* // `deflang` mandatory from v1.9, order with `NOUICOMPAT` may vary
	fonttbl? colortbl? stylesheet? listtables?;

charset: (ANSI | MAC | PC | PCA)? (ANSICPG)?;

// default font
from: FROMTEXT | FROMHTML;

// prevent matching empty string
deffont: (DEFFN | ADEFFN)+ (
		STSHFDBCHN STSHFLOCHN STSHFHICHN STSHFBIN
	)?;

// prevent matching empty string
deflang: (DEFLANGN | DEFLANGFEN | ADEFLANGN)+;

// font table
fonttbl:
	OPENING_BRACE FONTTBL (
		fontinfo
		| (OPENING_BRACE fontinfo CLOSING_BRACE)
	)+ CLOSING_BRACE;

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

fontemb:
	OPENING_BRACE FONTEMB fonttype (
		fontfname
		| data
		| fontfname data
	) CLOSING_BRACE;
fonttype: FTNIL | FTTRUETYPE;
fontfname:
	OPENING_BRACE FONTFILE CODEPAGE? pcdata CLOSING_BRACE;
fontname: pcdata;
fontaltname: OPENING_BRACE FALT pcdata CLOSING_BRACE;

// color table
colortbl: OPENING_BRACE COLORTBL colordef+ CLOSING_BRACE;

colordef: REDN? GREENN? BLUEN? SEMICOLON;

// stylesheet
stylesheet: OPENING_BRACE STYLESHEET style+ CLOSING_BRACE;
style:
	OPENING_BRACE styledef? keycode? formatting additive? based? next? formatting?
	// libreoffice place `formattting` after `next`
	autoupd? hidden? personal? compose? reply? stylename? SEMICOLON CLOSING_BRACE;
styledef: S | CS | DS;
keycode: OPENING_BRACE KEYCODE keys CLOSING_BRACE;
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

formatting: (
		// brdrdef
		parfmt
		// | apoctl |tabdef |shading
		| chrfmt
	)+;
stylename: pcdata;

// msft-rtf-1_9_1.pdf page 30
listtables: (listtable | listoverridetable)+;
listtable: OPENING_BRACE '\\*' LISTTABLE list+ CLOSING_BRACE;
// listtable: '{' '\\*' LISTTABLE // listpicture? list+ '}'; listpicture: '{\\*' LISTPICTURE
// shppictlist '}';
list:
	'{' list+ '}'
	| (
		LIST LISTTEMPLATEIDN
		| (LISTSIMPLE | LISTHYBRID)
		| listlevel+
		| LISTRESTARTHDNN
		| LISTIDN
		| LISTNAME pcdata* SEMICOLON
		| LISTSTYLEIDN
		| LISTSTYLENAME
	);
listlevel:
	OPENING_BRACE LISTLEVEL listnumber+ listjustification+ (
		LEVELFOLLOWN
		| LEVELSTARTATN
		| LVLTENTATIVE? (
			LEVELOLDN
			| LEVELPREVN
			| LEVELPREVSPACEN
			| LEVELSPACEN
			| LEVELINDENTN
		)
		| leveltext
		| levelnumbers
		| LEVELLEGALN
		| LEVELNORESTARTN
		| chrfmt
		| LEVELPICTUREN
		| LIN
		| FIN
		| (JCLISTTAB TXN)
		| LINN
	)+ CLOSING_BRACE;
listnumber: LEVELNFCN | LEVELNFCNN;
listjustification: LEVELJCN | LEVELJCNN;
leveltext:
	OPENING_BRACE LEVELTEXT LEVELTEMPLATEIDN? sdata* DOT? ';'? CLOSING_BRACE;
levelnumbers:
	OPENING_BRACE LEVELNUMBERS sdata* ';'? CLOSING_BRACE;

listoverridetable:
	OPENING_BRACE LISTOVERRIDETABLE listoverride+ CLOSING_BRACE;
listoverride:
	'{' LISTOVERRIDE LISTIDN LISTOVERRIDECOUNTN LSN '}';

///// Document
document: documentInfo? docfmt* section+;

// TODO add other fields
documentInfo:
	OPENING_BRACE INFO (
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
	)* CLOSING_BRACE;

title: OPENING_BRACE TITLE pcdata CLOSING_BRACE;
subject: OPENING_BRACE SUBJECT pcdata CLOSING_BRACE;
author: OPENING_BRACE AUTHOR pcdata CLOSING_BRACE;
manager: OPENING_BRACE MANAGER pcdata CLOSING_BRACE;
company: OPENING_BRACE COMPANY pcdata CLOSING_BRACE;
operator: OPENING_BRACE OPERATOR pcdata CLOSING_BRACE;
category: OPENING_BRACE CATEGORY pcdata CLOSING_BRACE;
keywords: OPENING_BRACE KEYWORDS pcdata CLOSING_BRACE;
comment: OPENING_BRACE COMMENT pcdata CLOSING_BRACE;
doccomm: OPENING_BRACE DOCCOMM pcdata CLOSING_BRACE;
hlinkbase: OPENING_BRACE HLINKBASE pcdata CLOSING_BRACE;
creatim: OPENING_BRACE CREATIM time CLOSING_BRACE;
revtim: OPENING_BRACE REVTIM time CLOSING_BRACE;
printim: OPENING_BRACE PRINTIM time CLOSING_BRACE;
buptim: OPENING_BRACE BUPTIM time CLOSING_BRACE;
time: YRN? MON? DYN? HRN? MINN? SECN?;

//// Document formatting TODO add other formatting fields
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

//// Section
section: (secfmt | docfmt)* hdrftr? para+ ( SECT section)?;

secfmt: // These control words can appear anywhere in the section.
	(
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
		| SFTNNRLC
	);

//// Header Footer
hdrftr: OPENING_BRACE hdrctl para+ CLOSING_BRACE hdrftr?;

hdrctl:
	HEADER
	| FOOTER
	| HEADERL
	| HEADERR
	| HEADERF
	| FOOTERL
	| FOOTERR
	| FOOTERF;

// Paragraph text Wrap `para` in braces (See Other problem areas in RTF: Property changes)
para: OPENING_BRACE para CLOSING_BRACE | textpar | row;

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

/// Table definition
row: (tbldef cell+ tbldef ROW)
	| (tbldef cell+ ROW)
	| (cell+ tbldef ROW);
tbldef: TROWD TRGAPH; // TODO add remaining control words
cell: (nestrow? tbldef?) textpar+ CELL;
nestrow:
	nestcell+ OPENING_BRACE NESTTABLEPROPS tbldef NESTROW CLOSING_BRACE;
nestcell: textpar+ NESTCELL;

/// Character text
charText: atext | ptext | OPENING_BRACE charText CLOSING_BRACE;
ptext: (
		((chrfmt | parfmt | secfmt) SPACE?)
		| ((chrfmt | parfmt | secfmt)* data)
		// specification leads to left-recursion
		| ((chrfmt | parfmt | secfmt)+ charText+)
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

// Bullets and Numbering
pn: pnseclvl | pnpara;
pnseclvl: '{' PNSECLVL pndesc '}';
pnpara: pntext pnprops;
pntext: '{' PNTEXT charText '}';
pnprops: '{' '\\*' PN pnlevel pndesc '}';
pnlevel: PNLVLN | PNLVLBLT | PNLVLBODY | PNLVLCONT;
pndesc: ( pnnstyle | pnchrfmt | pntxtb | pntxta | pnfmt)+;
pnnstyle:
	PNCARD
	| PNDEC
	| PNUCLTR
	| PNUCRM
	| PNLCLTR
	| PNLCRM
	| PNORD
	| PNORDT
	| PNBIDIA
	| PNBIDIB
	| PNAIU
	| PNAIUD
	| PNAIUEO
	| PNAIUEOD
	| PNCHOSUNG
	| PNCNUM
	| PNDBNUM
	| PNDBNUMD
	| PNDBNUMK
	| PNDBNUML
	| PNDBNUMT
	| PNDECD
	| PNGANADA
	| PNGBNUM
	| PNGBNUMD
	| PNGBNUMK
	| PNGBNUML
	| PNIROHA
	| PNIROHAD
	| PNULDASH
	| PNULDASHD
	| PNULDASHDD
	| PNULHAIR
	| PNULTH
	| PNULWAVE
	| PNZODIAC
	| PNZODIACD
	| PNZODIACL;
pnchrfmt: (
		PNFN
		| PNFSN
		| PNB
		| PNI
		| PNCAPS
		| PNSCAPS
		| pnul
		| PNSTRIKE
		| PNCFN
	)+;
pnul: PNUL | PNULD | PNULDB | PNULNONE | PNULW;
pnjust: PNQC | PNQL | PNQR;
pnfmt: (
		PNNUMONCE
		| PNACROSS
		| PNINDENT
		| PNSPN
		| PNPREV
		| pnjust
		| PNSTARTN
		| PNHANG
		| PNRESTART
	)+;
pntxtb: OPENING_BRACE PNTXTB pcdata CLOSING_BRACE;
pntxta: OPENING_BRACE PNTXTA pcdata CLOSING_BRACE;

/// Special characters!
spec:
	CHDATE
	| CHDPL
	| CHDPA
	| CHTIME
	| CHPGN
	| SECTNUM
	| CHFTN
	| CHATN
	| CHFTNSEP
	| CHFTNSEPC
	| CELL
	| NESTCELL
	| ROW
	| NESTROW
	| PAR
	| SECT
	| PAGE
	| COLUMN
	| LINE
	| LBRN
	| SOFTPAGE
	| SOFTCOL
	| SOFTLINE
	| SOFTLHEIGHTN
	| TAB
	| EMDASH
	| ENDASH
	| EMSPACE
	| ENSPACE
	| QMSPACE
	| BULLET
	| LQUOTE
	| RQUOTE
	| LDBLQUOTE
	| RDBLQUOTE
	| FORMULA
	| NBSP
	| OPTIONAL_HYPHEN
	| NONBREAKING_HYPHEN
	| SUBENTRY
	| ZWBO
	| ZWNBO
	| ZWJ
	| ZWNJ;
// | HEX_NUMBER;

// Wrap `data` in braces (See Other problem areas in RTF: Property changes)
data:
	OPENING_BRACE data CLOSING_BRACE
	| spec
	| pcdata; // TODO add rest of data

// taken from 'Formal Syntax' section
sdata: HEX_NUMBER+;
pcdata: (
		~(
			OPENING_BRACE
			| CLOSING_BRACE
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
			// Color table
			| COLORTBL
			| REDN
			| GREENN
			| BLUEN
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
			// `spec`
			| CHDATE
			| CHDPL
			| CHDPA
			| CHTIME
			| CHPGN
			| SECTNUM
			| CHFTN
			| CHATN
			| CHFTNSEP
			| CHFTNSEPC
			| CELL
			| NESTCELL
			| ROW
			| NESTROW
			| PAR
			| SECT
			| PAGE
			| COLUMN
			| LINE
			| LBRN
			| SOFTPAGE
			| SOFTCOL
			| SOFTLINE
			| SOFTLHEIGHTN
			| TAB
			| EMDASH
			| ENDASH
			| EMSPACE
			| ENSPACE
			| QMSPACE
			| BULLET
			| LQUOTE
			| RQUOTE
			| LDBLQUOTE
			| RDBLQUOTE
			| FORMULA
			| NBSP
			| OPTIONAL_HYPHEN
			| NONBREAKING_HYPHEN
			| SUBENTRY
			| ZWBO
			| ZWNBO
			| ZWJ
			| ZWNJ
		)
		| SPACE
		| DOT
		| ESCAPED_OPENING_BRACE
		| ESCAPED_CLOSING_BRACE
		| ESCAPED_BACKSLASH
	)+;
