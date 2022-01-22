import { Popover } from '@headlessui/react';
import { EmojiHappyIcon } from '@heroicons/react/outline';
import { Picker } from 'emoji-mart';
import 'emoji-mart/css/emoji-mart.css';
import { useTheme } from 'lib/hooks';
import React, { useMemo } from 'react';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';

interface EditorProps {
  placeholder: string;
  setFieldValue: any;
  text: string;
  handleSubmit: any;
  editorRef: any;
  editor: any;
  forceUpdate: any;
}

function EmojiDropdown({ onEmojiClick }: { onEmojiClick: any }) {
  const { themeColors } = useTheme();
  return (
    <Popover as="div" className="z-10 relative">
      {({ open }) => (
        <>
          <Popover.Button
            as="button"
            className="flex items-center focus:outline-none"
          >
            <EmojiHappyIcon
              style={{ color: themeColors?.foreground }}
              className="h-5 w-5 "
            />
          </Popover.Button>

          {open && (
            <div>
              <Popover.Panel
                static
                className="origin-top-left absolute bottom-0 right-0"
              >
                <Picker
                  onClick={onEmojiClick}
                  title="Emojis"
                  showPreview={false}
                  native
                />
              </Popover.Panel>
            </div>
          )}
        </>
      )}
    </Popover>
  );
}

function CustomToolbar({ editor }: { editor: any }) {
  // @ts-ignore
  const onEmojiClick = (emojiObject) => {
    const range = editor?.getLength() - 1;
    editor?.insertText(range, emojiObject.native);
  };

  return (
    <div id="toolbar" className="flex items-center justify-between w-full">
      <div className="flex items-center">
        <button className="ql-bold" />
        <button className="ql-italic" />
        <button className="ql-strike" />
        <button className="ql-blockquote" />
        <button className="ql-code" />
        <button className="ql-list" value="ordered" />
        <button className="ql-list" value="bullet" />
        <button className="ql-code-block" />
        <button className="ql-link" />
      </div>
      <div className="ml-auto flex items-center space-x-2">
        <EmojiDropdown onEmojiClick={onEmojiClick} />
      </div>
    </div>
  );
}

export default function EditorEdit({
  placeholder,
  setFieldValue,
  text,
  handleSubmit,
  editorRef,
  editor,
  forceUpdate,
}: EditorProps) {
  const modules = useMemo(
    () => ({
      toolbar: {
        container: '#toolbar',
      },
      clipboard: {
        matchVisual: false,
      },
      keyboard: {
        bindings: {
          tab: false,
          custom: {
            key: 13,
            shiftKey: true,
            handler: () => {
              handleSubmit();
            },
          },
          // linebreak: {
          //   key: 13,
          //   shiftKey: true,
          //   handler: (range: any, _context: any) => {
          //     unprivilegedEditor.clipboard.dangerouslyPasteHTML(
          //       range.index,
          //       '<p><br/><br/></p>'
          //     );
          //   },
          // },
        },
      },
    }),
    []
  );

  return (
    <div className="flex flex-col w-full">
      <ReactQuill
        onChange={(e) => {
          setFieldValue('text', e);
          forceUpdate();
        }}
        value={text}
        placeholder={placeholder}
        modules={modules}
        formats={[
          'bold',
          'italic',
          'strike',
          'list',
          'code',
          'link',
          'blockquote',
          'code-block',
        ]}
        theme="snow"
        ref={editorRef}
        className="editor"
      />
      <CustomToolbar editor={editor} />
    </div>
  );
}
