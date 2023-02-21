import org.antlr.v4.runtime.*;
import java.util.List;

abstract class RtfLexerBase extends Lexer {
    private int nestingLevel = 0;
    private static List<String> knownControlWords = List.of(
        "fname", "fontemb", "fontfile", "falt"
    );

    protected RtfLexerBase(CharStream input) {
        super(input);
    }

    void openingBrace(){
        nestingLevel++;
    }

    void closingBrace(){
        if(--nestingLevel == 0) popMode();
    }
}