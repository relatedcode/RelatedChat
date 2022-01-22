import { EditPasswordContext, ThemeContext } from 'lib/context';
import { useContext, useState } from 'react';

export function useTheme() {
  return useContext(ThemeContext);
}

export function useEditPasswordModal() {
  return useContext(EditPasswordContext);
}

export function useCreateMessageModal() {
  const [open, setOpen] = useState(false);
  const [section, setSection] = useState<'channels' | 'members'>('channels');
  return { open, setOpen, section, setSection };
}

export function useCreateChannelModal() {
  const [open, setOpen] = useState(false);
  return { open, setOpen };
}

export function useInviteTeammatesModal() {
  const [open, setOpen] = useState(false);
  return { open, setOpen };
}

export function usePreferencesModal() {
  const [open, setOpen] = useState(false);
  return { open, setOpen };
}

export function useWorkspaceSettingsModal() {
  const [open, setOpen] = useState(false);
  const [section, setSection] = useState<'members' | 'settings'>('members');
  return { open, setOpen, section, setSection };
}

export function useCreateWorkspaceModal() {
  const [open, setOpen] = useState(false);
  return { open, setOpen };
}

export function useForceUpdate() {
  const [value, setValue] = useState(0);
  return () => setValue(value + 1);
}
