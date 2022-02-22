export interface SSHPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
