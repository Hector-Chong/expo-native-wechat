import { Recordable } from "./typing";

export const getRamdomStr = () => (Math.random() + 1).toString(36).substring(7);

export const executeNativeFunction = (fn: Function) => {
  return (args: Recordable = {}) => {
    const id = getRamdomStr();

    fn({ ...args, id });

    return id;
  };
};
