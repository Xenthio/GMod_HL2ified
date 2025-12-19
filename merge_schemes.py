import re
import os

class Node:
    def __init__(self, type, content=None, key=None, value=None, conditional=None):
        self.type = type # 'section', 'property', 'comment', 'whitespace'
        self.content = content # raw text for whitespace/comment
        self.key = key
        self.value = value
        self.conditional = conditional
        self.children = [] # for section
        self.parent = None

    def __repr__(self):
        if self.type == 'section':
            return f"<Section {self.key}>"
        elif self.type == 'property':
            return f"<Property {self.key}: {self.value} [{self.conditional}]>"
        else:
            return f"<{self.type}>"

def tokenize(content):
    """
    A simple tokenizer/parser for VDF.
    Returns a list of root Nodes.
    """
    nodes = []
    stack = [nodes] # Stack of child lists
    
    i = 0
    length = len(content)
    
    while i < length:
        # 1. Whitespace
        if content[i].isspace():
            start = i
            while i < length and content[i].isspace():
                i += 1
            stack[-1].append(Node('whitespace', content=content[start:i]))
            continue
            
        # 2. Comment
        if content[i:i+2] == '//':
            start = i
            # Read until newline
            while i < length and content[i] != '\n':
                i += 1
            stack[-1].append(Node('comment', content=content[start:i]))
            continue
            
        # 3. Structural '}'
        if content[i] == '}':
            i += 1
            if len(stack) > 1:
                stack.pop()
            continue

        # 4. String (Key)
        key = ""
        if content[i] == '"':
            i += 1
            start = i
            while i < length and content[i] != '"':
                i += 1
            key = content[start:i]
            i += 1 # skip closing quote
        else:
            # Unquoted string
            start = i
            while i < length and not content[i].isspace() and content[i] not in '{}"':
                i += 1
            key = content[start:i]
            
            if not key:
                # Prevent infinite loop if we hit a character that stops the unquoted string parser
                # but wasn't handled (like '{' appearing unexpectedly)
                i += 1
                continue
            
        # Check for Section Start or Property Value
        # We need to skip whitespace/comments to find the next token
        
        # Look ahead
        j = i
        found_val = False
        is_section = False
        val = None
        cond = None
        
        while j < length:
            if content[j].isspace():
                j += 1
                continue
            if content[j:j+2] == '//':
                # Comment between key and value? Rare but possible.
                # We'll just stop looking and let the main loop handle it?
                # No, we need to know if it's a section or property.
                # If we hit a comment, we assume the key was a property with no value? No, VDF keys always have values or are sections.
                # Actually, comments can appear anywhere.
                # Let's just consume whitespace/comments in the lookahead?
                # This is getting complex. Let's simplify:
                # We just read a token. It's either a key for a property, a key for a section, or '}'
                
                # Wait, if we hit '}', we are closing a section.
                # But we just read a "key". '}' cannot be a key unless quoted.
                # If unquoted '}' was read, it's the end of section.
                break
            
            if content[j] == '{':
                is_section = True
                i = j + 1
                break
            elif content[j] == '}':
                # Should not happen if we just read a key.
                # Unless the key was actually '}'?
                break
            else:
                # It's a value
                found_val = True
                # Read value
                if content[j] == '"':
                    j += 1
                    vstart = j
                    while j < length and content[j] != '"':
                        j += 1
                    val = content[vstart:j]
                    j += 1
                else:
                    vstart = j
                    while j < length and not content[j].isspace() and content[j] not in '{}"':
                        j += 1
                    val = content[vstart:j]
                
                # Check for conditional
                # Skip whitespace
                k = j
                while k < length and content[k].isspace() and content[k] != '\n':
                    k += 1
                
                if k < length and content[k] == '[':
                    # Conditional found
                    cstart = k
                    while k < length and content[k] != ']':
                        k += 1
                    k += 1 # include ]
                    cond = content[cstart:k]
                    j = k
                
                i = j
                break
        
        if key == '}' and not found_val and not is_section:
             # End of section
             if len(stack) > 1:
                 stack.pop()
             continue

        if is_section:
            node = Node('section', key=key)
            stack[-1].append(node)
            stack.append(node.children)
        elif found_val:
            node = Node('property', key=key, value=val, conditional=cond)
            stack[-1].append(node)
        else:
            # Could be just '}' if we parsed it as a key?
            if key == '}':
                if len(stack) > 1:
                    stack.pop()
            else:
                # Dangling key?
                pass
                
    return nodes

def serialize_nodes(nodes):
    out = ""
    for node in nodes:
        if node.type == 'whitespace':
            out += node.content
        elif node.type == 'comment':
            out += node.content
        elif node.type == 'property':
            out += f'"{node.key}"\t\t"{node.value}"'
            if node.conditional:
                out += f'\t{node.conditional}'
        elif node.type == 'section':
            out += f'"{node.key}"'
            out += "\n\t{\n" # Default formatting for sections if whitespace missing
            out += serialize_nodes(node.children)
            out += "\n\t}"
    return out

def filter_conditionals(nodes):
    """
    Removes nodes with incompatible conditionals.
    Returns filtered list.
    """
    new_nodes = []
    for node in nodes:
        if node.type == 'property' and node.conditional:
            cond = node.conditional.strip('[]')
            keep = False
            
            # Logic:
            # We are on PC (WIN32).
            # $WIN32 -> True
            # $X360 -> False
            # $LINUX -> False
            # $OSX -> False
            # $DECK -> False
            
            # !Condition -> Invert
            
            is_not = cond.startswith('!')
            tag = cond[1:] if is_not else cond
            
            match = False
            if tag == '$WIN32': match = True
            elif tag == '$X360': match = False
            elif tag == '$LINUX': match = False
            elif tag == '$OSX': match = False
            elif tag == '$DECK': match = False
            # Add others if needed
            
            if is_not:
                keep = not match
            else:
                keep = match
                
            if keep:
                # Keep the node, strip the conditional
                node.conditional = None
                new_nodes.append(node)
            else:
                # Drop the node
                pass
        elif node.type == 'section':
            node.children = filter_conditionals(node.children)
            new_nodes.append(node)
        else:
            new_nodes.append(node)
    return new_nodes

def find_child_section(nodes, key):
    for node in nodes:
        if node.type == 'section' and node.key.lower() == key.lower():
            return node
    return None

def find_child_property(nodes, key):
    for node in nodes:
        if node.type == 'property' and node.key.lower() == key.lower():
            return node
    return None

def merge_trees(base_nodes, override_nodes):
    """
    Merges override_nodes into base_nodes.
    """
    for node in override_nodes:
        if node.type == 'whitespace' or node.type == 'comment':
            continue
            
        if node.type == 'section':
            base_section = find_child_section(base_nodes, node.key)
            if base_section:
                # Recursively merge
                merge_trees(base_section.children, node.children)
            else:
                # Add new section
                base_nodes.append(Node('whitespace', content="\n\t\t"))
                base_nodes.append(node)
                
        elif node.type == 'property':
            base_prop = find_child_property(base_nodes, node.key)
            if base_prop:
                # Update value
                base_prop.value = node.value
                base_prop.conditional = node.conditional
            else:
                # Add new property
                base_nodes.append(Node('whitespace', content="\n\t\t"))
                base_nodes.append(node)

def main():
    gmod_path = r"e:\SteamLibrary\steamapps\common\GMod_HL2ified\resource\ClientSchemeGMod.res"
    hl2_path = r"e:\SteamLibrary\steamapps\common\GMod_HL2ified\resource\ClientSchemeHL2.res"
    out_path = r"e:\SteamLibrary\steamapps\common\GMod_HL2ified\resource\clientscheme.res"
    
    with open(gmod_path, 'r', encoding='utf-8') as f:
        gmod_content = f.read()
        
    with open(hl2_path, 'r', encoding='utf-8') as f:
        hl2_content = f.read()
        
    print("Parsing GMod scheme...")
    gmod_nodes = tokenize(gmod_content)
    print("Parsing HL2 scheme...")
    hl2_nodes = tokenize(hl2_content)
    
    print("Filtering HL2 conditionals...")
    hl2_nodes = filter_conditionals(hl2_nodes)
    
    # Find Scheme sections
    gmod_scheme = find_child_section(gmod_nodes, "Scheme")
    hl2_scheme = find_child_section(hl2_nodes, "Scheme")
    
    if gmod_scheme and hl2_scheme:
        # Merge specific sections
        sections_to_merge = ["BaseSettings", "Fonts", "CustomFontFiles"]
        
        for sec_name in sections_to_merge:
            print(f"Merging {sec_name}...")
            gmod_sec = find_child_section(gmod_scheme.children, sec_name)
            hl2_sec = find_child_section(hl2_scheme.children, sec_name)
            
            if gmod_sec and hl2_sec:
                merge_trees(gmod_sec.children, hl2_sec.children)
            elif hl2_sec and not gmod_sec:
                # Add whole section
                gmod_scheme.children.append(hl2_sec)
    
    print("Writing output...")
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(serialize_nodes(gmod_nodes))
        
    print("Done!")

if __name__ == "__main__":
    main()
