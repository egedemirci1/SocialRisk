import os
import re

def process_dart_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    if 'GoogleFonts.' not in content:
        return

    # Loop as long as there is a GoogleFonts. call to process
    pattern = r'GoogleFonts\.([a-zA-Z]+)\s*\('
    
    while True:
        match = re.search(pattern, content)
        if not match:
            break
            
        font_name = match.group(1)
        start_idx = match.start()
        paren_start = match.end() - 1
        
        # We need to find the matching closing parenthesis
        paren_count = 1
        curr_idx = paren_start + 1
        
        while curr_idx < len(content) and paren_count > 0:
            if content[curr_idx] == '(':
                paren_count += 1
            elif content[curr_idx] == ')':
                paren_count -= 1
            curr_idx += 1
            
        if paren_count != 0:
            print(f"ERROR: Unmatched parenthesis in {filepath}")
            break
            
        end_paren = curr_idx - 1
        arguments = content[paren_start+1:end_paren].strip()
        
        # Don't touch Cinzel and Montserrat unless you want to
        if font_name in ['cinzel', 'montserrat']:
            # Replace temporarily so we don't process it again in the loop
            content = content[:start_idx] + "GoogleFonts_IGNORE." + font_name + "(" + arguments + ")" + content[curr_idx:]
            continue
            
        font_size = 14
        size_match = re.search(r'fontSize:\s*([0-9.]+)', arguments)
        if size_match:
            font_size = float(size_match.group(1))
            
        # Mapping logic
        replacement_base = "AppTextStyles.bodyMedium"
        if font_name == 'poppins':
            if font_size >= 30:
                replacement_base = 'AppTextStyles.displayLarge'
            elif font_size >= 24:
                replacement_base = 'AppTextStyles.displayMedium'
            elif font_size >= 20:
                replacement_base = 'AppTextStyles.headlineMedium'
            else:
                replacement_base = 'AppTextStyles.titleLarge'
        elif font_name == 'playfairDisplay':
            if font_size >= 20:
                replacement_base = 'AppTextStyles.headlineMedium'
            else:
                replacement_base = 'AppTextStyles.titleLarge'
        elif font_name == 'nunito' or font_name == 'inter' or font_name == 'libreBaskerville':
            if font_size >= 16:
                replacement_base = 'AppTextStyles.titleMedium'
            elif font_size == 14 or font_size == 15:
                replacement_base = 'AppTextStyles.titleSmall'
            elif font_size <= 13:
                replacement_base = 'AppTextStyles.labelSmall'
        
        if arguments:
            new_text = f"{replacement_base}.copyWith({arguments})"
        else:
            new_text = replacement_base
            
        content = content[:start_idx] + new_text + content[curr_idx:]
        
    # Put back the ignored fonts
    content = content.replace("GoogleFonts_IGNORE.", "GoogleFonts.")

    if content != original_content:
        # Add import if needed
        if 'app_text_styles.dart' not in content:
            pkg_import = "import 'package:social_risk/core/constants/app_text_styles.dart';\n"
            last_import_index = content.rfind("import '")
            if last_import_index != -1:
                newline_index = content.find('\n', last_import_index)
                if newline_index != -1:
                    content = content[:newline_index+1] + pkg_import + content[newline_index+1:]
                else:
                    content = pkg_import + content
            else:
                content = pkg_import + content
                
        # Remove empty GoogleFonts imports if none remain
        if 'GoogleFonts' not in content:
            content = re.sub(r"import\s+'package:google_fonts/google_fonts\.dart';\s*\n", "", content)

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {filepath}")

def main():
    lib_dir = os.path.join(os.getcwd(), 'lib')
    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart') and file != 'app_text_styles.dart':
                process_dart_file(os.path.join(root, file))

if __name__ == '__main__':
    main()
