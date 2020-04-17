require 'chord_parser'
require 'minitest/autorun'

# replace this with Rspec matchers that come with Parslet
class TestChordParser < Minitest::Test
  def setup
    @p = ChordParser.new
  end

  # def test_parsing_simple_root
  #   assert_equal @p.parse("C"), Chord.new(root: "C")
  # end

  # def test_parsing_simple_root_with_shorthand
  #   assert_equal @p.parse("Fsus4"), Chord.new(root: "C")
  # end

  # def test_parsing_simple_root_with_shorthand_and_interval
  #   assert_equal @p.parse("Fsus4b9"), Chord.new(root: "C")
  # end

  # def test_parsing_simple_root_with_interval
  #   assert_equal @p.parse("F6"), Chord.new(root: "C")
  # end

  # def test_parsing_slash_chords
  #   assert_equal @p.parse("F/G"), Chord.new(root: "C")
  # end

  # def test_parsing_multiple_shorthand
  #   assert_equal @p.parse("G7sus4"), Chord.new(root: "C")
  # end

  def test_parsing_chord_sequence
    #assert_equal @p.parse("Cmaj7 Am7 | "), Chord.new(root: "C")
    tree =  @p.parse("Cmaj7 Am7 | Dm9 G7sus4b9#11/B |
                   F#m7b5 B7alt | Eminmaj7 Emin6 ")
    pp ChordTransform.new.apply tree
    assert_equal @p.parse("Cmaj7 Am7 | Dm9 G7sus4b9#11/B |
                          F#m7b5 B7alt | Eminmaj7 Emin6 |"), Chord.new(root: "C")
    #assert_equal @p.parse("C7b9#11 A13sus4 | Dm9/A G13sus4b9#11"), Chord.new(root: "C")
  rescue Parslet::ParseFailed => error
    puts error.parse_failure_cause.ascii_tree
  end
end
