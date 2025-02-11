process
begin
    if count = 127 then
        count <= "10000000";
    else
        count <= count + 1;
    end if;
    X <= count;
    wait for sawtoothPeriod750/2**N;
end process;

-- process
-- begin
--     for j in -128 to 127 loop
--         X <= to_signed (j, N);
--         wait for sawtoothPeriod750/2**N;
--     end loop;
-- end process;
