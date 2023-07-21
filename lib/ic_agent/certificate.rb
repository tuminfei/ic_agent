module IcAgent
  class NodeId
    EMPTY = 0
    FORK = 1
    LABELED = 2
    LEAF = 3
    PRUNED = 4
  end

  class Certificate
    # Performs a lookup operation in the certificate tree based on the given path.
    #
    # Parameters:
    # - path: The path to lookup.
    # - cert: The certificate object containing the tree.
    #
    # Returns: The value found at the specified path in the tree.
    def self.lookup(path, cert)
      lookup_path(path, cert.value['tree'])
    end

    # Retrieves the signature from a certificate.
    #
    # Parameters:
    # - cert: The certificate object.
    #
    # Returns: The signature value.
    def self.signature(cert)
      cert.value['signature']
    end

    # Retrieves the delegation from a certificate.
    #
    # Parameters:
    # - cert: The certificate object.
    #
    # Returns: The delegation value.
    def self.delegation(cert)
      cert.value['delegation']
    end

    # Retrieves the tree from a certificate.
    #
    # Parameters:
    # - cert: The certificate object.
    #
    # Returns: The tree value.
    def self.tree(cert)
      cert.value['tree']
    end

    private

    # Recursive helper method for performing the lookup operation.
    #
    # Parameters:
    # - path: The remaining path to lookup.
    # - tree: The current tree node to search in.
    #
    # Returns: The value found at the specified path in the tree.
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

    # Flattens fork nodes in the tree into a single array.
    #
    # Parameters:
    # - t: The tree node to flatten.
    #
    # Returns: The flattened array of tree nodes.
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

    # Finds a labeled tree node with the specified label in the given array of trees.
    #
    # Parameters:
    # - l: The label to search for.
    # - trees: The array of trees to search in.
    #
    # Returns: The labeled tree node with the matching label, or nil if not found.
    def self.find_label(l, trees)
      trees.each do |t|
        if t[0] == NodeId::LABELED
          p = t[1]
          return t[2] if l == p
        end
      end
      nil
    end

    # Recursively reconstructs the hash value of a tree node.
    #
    # Parameters:
    # - t: The tree node to reconstruct.
    #
    # Returns: The reconstructed hash value of the tree node.
    def self.reconstruct(t)
      case t[0]
      when IcAgent::NodeId::EMPTY
        domain_sep = domain_sep('ic-hashtree-empty')
        Digest::SHA256.digest(domain_sep)
      when IcAgent::NodeId::PRUNED
        t[1]
      when IcAgent::NodeId::LEAF
        domain_sep = domain_sep('ic-hashtree-leaf')
        Digest::SHA256.digest(domain_sep + t[1])
      when IcAgent::NodeId::LABELED
        domain_sep = domain_sep('ic-hashtree-labeled')
        Digest::SHA256.digest(domain_sep + t[1] + reconstruct(t[2]))
      when IcAgent::NodeId::FORK
        domain_sep = domain_sep('ic-hashtree-fork')
        Digest::SHA256.digest(domain_sep + reconstruct(t[1]) + reconstruct(t[2]))
      else
        raise 'unreachable'
      end
    end

    # Generates the domain separation prefix for hash computations.
    #
    # Parameters:
    # - s: The domain separation string.
    #
    # Returns: The domain separation prefix as a binary string.
    def self.domain_sep(s)
      len = [s.bytesize].pack('C')
      str = s.encode(Encoding::UTF_8)
      len + str
    end
  end
end
