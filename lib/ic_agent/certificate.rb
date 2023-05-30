module IcAgent
  class NodeId
    EMPTY = 0
    FORK = 1
    LABELED = 2
    LEAF = 3
    PRUNED = 4
  end

  class Certificate
    def self.lookup(path, cert)
      lookup_path(path, cert.value['tree'])
    end

    def self.lookup_path(path, tree)
      offset = 0
      if path.length == 0
        if tree[0] == NodeId::LEAF
          return tree[1]
        else
          return nil
        end
      end
      label = path[0].is_a?(String) ? path[0].encode : path[0]
      t = find_label(label, flatten_forks(tree))
      if t
        offset += 1
        lookup_path(path[offset..-1], t)
      end
    end

    def self.flatten_forks(t)
      if t[0] == NodeId::EMPTY
        []
      elsif t[0] == NodeId::FORK
        val1 = flatten_forks(t[1])
        val2 = flatten_forks(t[2])
        val1.concat(val2)
        val1
      else
        [t]
      end
    end

    def self.find_label(l, trees)
      trees.each do |t|
        if t[0] == NodeId::LABELED
          p = t[1]
          return t[2] if l == p
        end
      end
      nil
    end
  end
end
