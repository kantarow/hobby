module Shannon
  class Symbol
    attr_accessor :sym, :prob

    def initialize(sym, prob)
      @sym = sym
      @prob = prob
    end

    include Comparable

    def <=>(other)
      self.prob <=> other.prob
    end

    def self.create_from_array(syms:, probs:)
      unless syms.length == probs.length
        raise "syms and probs must be same length"
      end
      
      syms.zip(probs).map do |sym, prob|
        self.new(sym, prob)
      end
    end
  end

  class Node
    attr_accessor :left, :right

    def initialize(syms)
      @syms = syms.sort.reverse
    end

    def smooth_split
      return nil if @syms.length == 1
      syms = @syms.sort.reverse
      right = 0
      left = 0

      syms.each do |sym|
        right += sym.prob
      end

      diffs = syms.length.times.map do |i|
        right -= syms[i].prob
        left += syms[i].prob
        (right - left).abs
      end

      split_index = diffs.index(diffs.min)
      return Node.new(syms.slice(0..split_index)), Node.new(syms.slice((split_index + 1)..-1))
    end

    def self.make_tree(node)
      node.left, node.right = node.smooth_split
      if node.right && node.left
        make_tree(node.right)
        make_tree(node.left)
      end
      return node
    end
  end
end

syms = Shannon::Symbol.create_from_array(syms: (1..10).map(&:to_i).to_a, probs: [0.4, 0.03, 0.23, 0.23, 0.09, 0.14, 0.4, 0.15, 0.12, 0.1])
node = Shannon::Node.new(syms)
tree = Shannon::Node.make_tree(node)

pp tree
