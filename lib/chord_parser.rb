require 'parslet'

# From SYMBOLIC REPRESENTATION OF MUSICAL CHORDS: A PROPOSED
# SYNTAX FOR TEXT ANNOTATIONS
# Christopher Harte, Mark Sandler and Samer Abdallah QMUL
# Emilia Gomez
# http://ismir2005.ismir.net/proceedings/1080.pdf
#
# <chord> ::= <note> ":" <shorthand> ["("<degree-list>")"]["/"<degree>] | <note> ":" "("<degree-list>")" ["/"<degree>] | <note> ["/"<degree>] | "N"
# <note> ::= <natural> | <note> <modifier>
# <natural> ::= A | B | C | D | E | F | G
# <modifier> ::= b | #
# <degree-list> ::= ["*"] <degree> ["," <degree-list>]
# <degree> ::= <interval> | <modifier> <degree>
# <interval> ::= 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13
# <shorthand> ::= maj | min | dim | aug | maj7 | min7 | 7 | dim7 | hdim7 | minmaj7 | maj6 | min6 | 9 | maj9 | min9 | sus4

class Chord
  attr_accessor :root

  def initialize(root: nil)
    @root = root
  end
end

class ChordParser < Parslet::Parser
  rule(:natural) { match('[A-G]').repeat(1) }
  rule(:modifier) { str('#') | str('b') | str('no') | str('omit') }
  rule(:note) { natural >> modifier.maybe }
  rule(:degree_list) { (degree >> str(',').maybe).repeat }
  rule(:degree) { (modifier.maybe >> interval).as(:degree) }
  rule(:interval) { 
    str('root') | \
    str('2') | str('3') | str('4') | \
    str('5') | \
    # str('6') | str('7') | str('8') | \
    str('9') | str('10') | str('11') | str('12') | str('13')
  }
  rule(:shorthand) {
    (str('maj') | str('min') | str('dim') | \
    str('aug') | str('aug7') | str('maj7') | str('min7') | \
    str('7') | str('dim7') | str('hdim7') | str('m7') | \
    str('alt') | \
    str('minmaj7') | str('maj6') | str('min6') | str('6') | \
    str('add9') | str('6/9') | str('min6/9') | \
    str('m') | str('M') | \
    str('13') | str('11') | \
    str('sus2') | str('sus4') | \
    str('9') | str('maj9') | str('min9')).as(:quality)
  }
  rule(:bass_note) { str('/') >> note.as(:bass_note) }
  rule(:chord) {
    (
      (note.as(:root) >> shorthand.repeat(1) >> degree_list >> bass_note) | \
      (note.as(:root) >> shorthand.repeat(1) >> degree_list) | \
      (note.as(:root) >> shorthand.repeat(1) >> bass_note) | \
      (note.as(:root) >> shorthand.repeat(1)) | \
      #
      # The only case for the following I can think of
      # is F11 and even then it's borderline
      (note.as(:root) >> degree_list ) | \
      (note.as(:root) >> bass_note) | \
      (note.as(:root))
    ).as(:chord)
  }
  rule(:space)  { match('\s').repeat(1) }
  rule(:space?) { space.maybe }
  rule(:bar) {
    (space? >> chord.as(:chord) >> (space? | any.absent?)).repeat(1).as(:bar) >> str('|').maybe
  }
  rule(:sequence) { bar.repeat }

  root(:sequence)
end

class ChordTransform < Parslet::Transform
  NOTES = (%w{c d e f g a b}.zip([0,2,4,5,7,9,11])).to_h

  rule(:root => simple(:x)) { {root: NOTES[x.to_s.downcase]} }
  rule(:quality => simple(:x)) { 
    case x.to_s
    when "sus4"
      {sus4: 5, is_suspended: true} 
    else
      x
    end
  }
end
