import { IColor } from "App";
import React, { createContext } from "react";

interface IThemeContext {
  theme: string;
  setTheme: React.Dispatch<React.SetStateAction<string>>;
  themeColors: IColor | null;
}

export const ThemeContext = createContext<IThemeContext>({
  theme: "",
  setTheme: () => {},
  themeColors: null,
});

export const CreateMessageContext = createContext({
  open: false,
  setOpen: null as any,
  section: "",
  setSection: null as any,
});

export const CreateChannelContext = createContext({
  open: false,
  setOpen: null as any,
});

export const InviteTeammatesContext = createContext({
  open: false,
  setOpen: null as any,
});

export const PreferencesContext = createContext({
  open: false,
  setOpen: null as any,
});

export const EditPasswordContext = createContext({
  open: false,
  setOpen: null as any,
});

export const WorkspaceSettingsContext = createContext({
  open: false,
  setOpen: null as any,
  section: "",
  setSection: null as any,
});

export const CreateWorkspaceContext = createContext({
  open: false,
  setOpen: null as any,
});

export const UserContext = createContext({
  user: null as any,
  userdata: null as any,
});

export const AllChannelsContext = createContext({
  channels: null as any,
  setChannels: null as any,
});

export const ChannelsContext = createContext({
  value: null as any,
  loading: true,
});

export const DirectMessagesContext = createContext({
  value: null as any,
  loading: true,
});

export const MessagesContext = createContext({
  messages: null as any,
  setMessages: null as any,
});

export const PresencesContext = createContext({
  presences: null as any,
  setPresences: null as any,
});

export const UsersContext = createContext({
  value: null as any,
  loading: true,
});

export const DetailsContext = createContext({
  value: null as any,
  loading: true,
});
