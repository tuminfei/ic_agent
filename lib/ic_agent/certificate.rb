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

    def self.signature(cert)
      cert.value['signature']
    end

    def self.delegation(cert)
      cert.value['delegation']
    end

    def self.tree(cert)
      cert.value['tree']
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

    def self.reconstruct(t)
      case t[0]
      when IcAgent::NodeId::EMPTY # NodeId.Empty
        domain_sep = domain_sep('ic-hashtree-empty')
        Digest::SHA256.digest(domain_sep)
      when IcAgent::NodeId::PRUNED # NodeId.Pruned
        t[1]
      when IcAgent::NodeId::LEAF # NodeId.Leaf
        domain_sep = domain_sep('ic-hashtree-leaf')
        Digest::SHA256.digest(domain_sep + t[1])
      when IcAgent::NodeId::LABELED # NodeId.Labeled
        domain_sep = domain_sep('ic-hashtree-labeled')
        Digest::SHA256.digest(domain_sep + t[1] + reconstruct(t[2]))
      when IcAgent::NodeId::FORK # NodeId.Fork
        domain_sep = domain_sep('ic-hashtree-fork')
        Digest::SHA256.digest(domain_sep + reconstruct(t[1]) + reconstruct(t[2]))
      else
        raise 'unreachable'
      end
    end

    def self.domain_sep(s)
      len = [s.bytesize].pack('C')
      str = s.encode(Encoding::UTF_8)
      len + str
    end
  end
end
